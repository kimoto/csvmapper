#!/bin/env ruby
# encoding: utf-8
# Author: kimoto

require 'csvmapper'
class MyCSV < CSVMapper
  column :name, 0, :string
  column :ipaddr, 1, :ipaddr
  column :file_path, 2, :pathname
  column :time, 3, :time
end

puts MyCSV.load("name1,127.0.0.1,./tmp/path/to/file.txt,2012/01/01").to_json
  # => [{"name":"name1","ipaddr":"127.0.0.1","file_path":"./tmp/path/to/file.txt","time":"2012-01-01 00:00:00 +0900"}]

