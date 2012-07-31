require "csvmapper/version"

require 'csv'
require 'hashie'
require 'json'
require 'pathname'
require 'time'
require 'ipaddr'
require 'uri'

class CSVMapper
  @@data = []
  @@ignore_header_line = false
  @@on_error_go_to_next_line = false
  @@has_header = nil
  @@delimiter = ','

  def self.column(field, *args, &block)
    value = args.shift
    #value = block.call(value) if block_given?
    record = {
      field => value,
      :options => args,
      :filter => block
    }
    @@data << record
  end

  def self.has_header(at=0)
    @@has_header = at
  end

  def self.load_file(path)
    self.load(File.read(path))
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
      if @@has_header == index
        line.each_with_index{ |name, i|
          self.column(name.gsub(" ", "_").downcase, i, :string)
        }
        next
      end

      hash = {}
      @@data.each{ |opt|
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

  def initialize(records=[])
    @records = records.map{ |hash|
      Hashie::Mash.new(hash)
    }
  end

  def row(index)
    @records[index]
  end

  def [](index)
    row(index)
  end

  def to_hash
    @records.map{ |record|
      record.to_hash
    }
  end

  def to_json
    @records.to_json
  end
end

