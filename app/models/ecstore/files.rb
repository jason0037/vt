#encoding:utf-8
class  Ecstore::Files < Ecstore::Base
  self.table_name = "sdb_cheuks_files"
  attr_accessible :desc, :file, :name ,:url
end
