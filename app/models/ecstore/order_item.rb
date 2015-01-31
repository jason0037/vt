class Ecstore::OrderItem < Ecstore::Base
	self.table_name = "sdb_b2c_order_items"
	belongs_to :order, :foreign_key=>"order_id"

	belongs_to :product, :foreign_key=>"product_id"
	belongs_to :good, :foreign_key=>"goods_id"
  belongs_to :ecstore_goods_promotion_ref, :class_name => 'Ecstore::GoodsPromotionRef', :foreign_key=>"ref_id"
	has_many :reship_items, :foreign_key=>"order_item_id"


	def reship_nums
		reship_items.sum(:number)
	end



	# before_save :calculate_amount

	# def calculate_amount
	# 	self.amount = self.price * self.nums
	# end

	def addon
		super.deserialize
	end

end