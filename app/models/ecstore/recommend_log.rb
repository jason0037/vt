#encoding:utf-8
class Ecstore::RecommendLog < Ecstore::Base
	self.table_name  = 'sdb_imodec_recommend_log'
	self.accessible_all_columns

	has_one :bill, :foreign_key=>"bill_id", :conditions => {:bill_type=>"refunds"}

  belongs_to :user,:foreign_key=>"member_id"
  belongs_to :good,:foreign_key=>"goods_id"

end