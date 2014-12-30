#encoding:utf-8
class Ecstore::Ghistory < Ecstore::AbstractPage
  self.table_name = "sdb_cheuks_ghistories"
  attr_accessible :goods_id, :ip, :member_id

end
