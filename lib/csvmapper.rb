require "csvmapper/version"
require 'csv'
require 'hashie'
require 'json'
require 'pathname'
require 'time'
require 'ipaddr'
require 'uri'
require 'open-uri'

class CSVMapper
  @@schema = []
  @@ignore_header_line = false
  @@on_error_go_to_next_line = false
  @@has_header = nil
  @@delimiter = ','
  @@before_filters = []

  def self.column(field, *args, &block)
    value = args.shift
    record = {
      field => value,
      :options => args,
      :filter => block
    }
    @@schema << record
  end

  def self.columns(*fields)
    fields.each_with_index{ |field, index|
      self.column(field, index, :string)
    }
  end

  def self.has_header(at=0)
    @@has_header = at
  end

  def self.load_file(path, encoding = nil)
    data = open(path).read
    data.force_encoding(encoding) if encoding
    self.load(data)
  end

  def self.load(data)
    buf = CSV.parse(data, :col_sep => @@delimiter)
    if @@ignore_header_line
      @@ignore_header_line_count.times{
        buf.shift()
      }
    end

    records = []
    buf.each_with_index{ |line, index|
      if line.empty?
        next
      end

      if @@has_header == index
        line.each_with_index{ |name, i|
          self.column(name.gsub(" ", "_").downcase, i, :string)
        }
        next
      end

      line = line.map{ |item|
        @@before_filters.each{ |filter|
          item = filter.call(item)
        }
        item
      }

      hash = {}
      @@schema.each{ |opt|
        key = opt.keys.first
        options = opt[:options]

        if options.empty?
          index = opt[key]
          hash[key] = line[index]
        else
          klass = options.first
          index = opt[key]

          if line[index].nil?
            hash[key] = nil
            next
          end

          begin
            case klass
            when :string
              hash[key] = line[index].to_s
            when :numeric
              hash[key] = line[index].to_i
            when :pathname
              hash[key] = Pathname.new(line[index])
            when :time
              hash[key] = Time.parse(line[index])
            when :unixtime
              hash[key] = Time.at(line[index].to_i)
            when :date
              hash[key] = Date.parse(line[index])
            when :boolean
              hash[key] = line[index].to_s == "true" ? true : false
            when :ipaddr
              hash[key] = IPAddr.new(line[index])
            when :uri
              hash[key] = URI.parse(line[index])
            when :regexp
              hash[key] = Regexp.compile(line[index])
            else
              raise "not implemented yet"
            end
          rescue => ex
            puts ex
            puts ex.backtrace.join($/)

            if @@on_error_go_to_next_line
              puts "========"
              puts "Ignore error!!"
              puts "========"
              next
            else
              raise ex
            end
          end

          ## filterは最後に適用
          if opt[:filter]
            hash[key] = opt[:filter].call(hash[key])
          end
        end
      }
      records << hash
    }
    self.new(records)
  end

  def self.ignore_header_line(line_count=1)
    @@ignore_header_line = true
    @@ignore_header_line_count = line_count
  end

  def self.on_error_go_to_next_line
    @@on_error_go_to_next_line = true
  end

  def self.delimiter(val)
    @@delimiter = val
  end

  def self.before_filter(&block)
    @@before_filters << block
  end

  def initialize(records=[])
    @records = records.map{ |hash|
      Hashie::Mash.new(hash)
    }
  end

  def row(index)
    @records[index]
  end

  ## size
  def rows
    @records.size
  end

  def cols
    if @records.nil? or @records.empty?
      return 0
    else
      return @records.first.size
    end
  end

  def [](index)
    row(index)
  end

  include Enumerable
  def each(&block)
    matched = []
    if @where
      @records.each{ |record|
        @where.each{ |key, value|
          if record.send(key) == value
            matched << record
          end
        }
      }
    else
      matched = @records
    end

    matched.each{ |e|
      block.call(e)
    }
  end

  ## arel style finder
  def where(options={})
    @where = Hashie::Clash.new(options) if @where.nil?
    @where.merge! options
    self
  end

  def order(options={})
    @order = Hashie::Clash.new(options) if @order.nil?
    @order.merge! options
    self
  end

  def to_hash
    @records.map{ |record|
      record.to_hash
    }
  end

  def to_json
    @records.to_json
  end

  def grouped_by(field)
    hash = {}
    each{|e|
      k = e[field]
      hash[k] ||= []
      hash[k] << e
    }
    hash
  end
end

