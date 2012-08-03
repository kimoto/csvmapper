# encoding: utf-8
require 'csvmapper'
require 'cgi'
require 'hashie'

class YPIndex < CSVMapper
  before_filter do |v|
    CGI.unescapeHTML(v) if v
  end

  delimiter '<>'
  column :name, 0, :string
  column :hash, 1
  column :host, 2
  column :contact, 3, :uri
  column :genre, 4
  column :description, 5
  column :active_viewers, 6, :numeric
  column :total_viewers, 7, :numeric
  column :bitrate, 8, :numeric
  column :filetype, 9
  column :artist, 10
  column :title, 11
  column :album, 12
  column :reserved, 13
  column :hash2, 14
  column :time, 15
  column :type, 16
  column :reservee, 17
  column :nullfield, 18
end

p YPIndex.load_file("http://temp.orz.hm/yp/index.txt").where(:name => 'あくえり').where(:genre => 'DQ3 SFC').first


