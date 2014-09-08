#encoding:utf-8
class Ecstore::Commission < Ecstore::Base

	self.table_name = "sdb_b2c_commissions"

  accessible_all_columns
  #attr_accessor :up_or_down

  belongs_to :account,:foreign_key=>"member_id"
  belongs_to :supplier, :foreign_key=>"supplier_id"
  belongs_to :wechat_follower, :foreign_key=>"openid"
end