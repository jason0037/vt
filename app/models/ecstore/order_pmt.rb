class Ecstore::OrderPmt < Ecstore::Base
	self.table_name = "sdb_imodec_order_promotions"
	belongs_to :order, :foreign_key=>"order_id"

	belongs_to :promotion,:foreign_key=>"pmt_id", :class_name=>"Promotion"
	belongs_to :coupon, :foreign_key=>"pmt_id",:class_name=>"NewCoupon"
	
end