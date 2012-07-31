# CSVMapper

CSV to Ruby Model

## Installation

Add this line to your application's Gemfile:

    gem 'csvmapper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install csvmapper

## Usage

    class MyCSV < CSVMapper
      column :name, 0, :integer
      column :ipaddr, 1, :ipaddr
      column :file_path, 2, :pathname
      column :time, 3, :time
    end

    p MyCSV.load("name1,127.0.0.1,./tmp/path/to/file.txt,2012/01/01")
      # => 

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
