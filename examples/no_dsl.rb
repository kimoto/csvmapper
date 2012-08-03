# encoding: utf-8
require 'csvmapper'
require 'cgi'

class MyCSV < CSVMapper
end

MyCSV.before_filter do |v|
  CGI.unescapeHTML(v) if v
end

MyCSV.delimiter '<>'
MyCSV.column :name, 0, :string
MyCSV.column :hash, 1
MyCSV.column :host, 2
MyCSV.column :contact, 3, :uri
MyCSV.column :genre, 4
MyCSV.column :description, 5
MyCSV.column :active_viewers, 6, :numeric
MyCSV.column :total_viewers, 7, :numeric

csv = MyCSV.load_file("http://temp.orz.hm/yp/index.txt")
p csv

