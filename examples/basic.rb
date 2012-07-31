#!/bin/env ruby
# encoding: utf-8
# Author: kimoto
require 'csvmapper'

class MyCSV < CSVMapper
  ignore_header_line 
  on_error_go_to_next_line 
  delimiter ','

  column :name, 0, :string, &:upcase
  column :age, 1, :numeric
  column :path, 2, :pathname, &:to_s
  column :time, 3, :time
  column :epoch, 4, :unixtime
  column :date, 5, :date
  column :bool, 6, :boolean 
  column :ip, 7, :ipaddr
  column :uri, 8, :uri
  column :regexp, 9, :regexp
end

csv_data = <<EOT
name,age,path,time,epoch,date,bool,ip,uri,regexp
kimoto,19,/home/kimoto/test.rb,2012-12-24 00:00:00,1343714611,2012-01-01,true,127.0.0.1,http://www.google.co.jp,a-zA-Z
takumi,24,/var/lib/tmp,2012/01/01 12:34:56,1343714611,2012/01/02,false,10.0.0.1,ftp://localhost/,^[0-9]+$
hebo,33,/cygdrive/c/test.txt,,1343714611,2012/01/03,false,10.0.0.2,steam://127.0.0.1/connect,[12345]
EOT

p MyCSV.load(csv_data)
