# encoding: utf-8
require 'csvmapper'
require 'cgi'

class OmgCSV < CSVMapper
  columns :first_name, :last_name, :age
end

csv = OmgCSV.load <<EOT
takumi,kimoto,99
super,urutoraman,11
EOT

p csv.map(&:age)
# => ["99", "11"]

