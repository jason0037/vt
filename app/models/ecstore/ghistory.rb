#encoding:utf-8
class Ecstore::Ghistory < Ecstore::Base
  self.table_name = "sdb_cheuks_ghistories"
  attr_accessible :goods_id, :ip, :member_id ,:status ,:id

end
