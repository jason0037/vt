require "digest/md5"
class Ecstore::Cart < Ecstore::Base
	self.table_name = 'sdb_b2c_cart_objects'

	belongs_to :user,:foreign_key=>"member_id"
  belongs_to :supplier,:foreign_key=>"supplier_id"

	default_scope where(:obj_type=>"goods")

	attr_accessible :obj_ident,:member_ident,:member_id,:obj_type,:params,:quantity,:time

	before_save :generate_params
	def generate_params
		return  if self.obj_type == "coupon"
		_obj_type, goods_id, product_id = self.obj_ident.split("_")

		self.params = {"goods_id"=>goods_id,
		 "product_id"=>product_id,
		 "adjunct"=>{},
		 "extends_params"=>nil}.serialize
	end

	def good
		return  if self.obj_type == "coupon"
		_obj_type, goods_id, product_id = self.obj_ident.split("_")
		@good ||= Ecstore::Good.find_by_goods_id(goods_id)  if goods_id
	end

	def goods_id
		_obj_type, goods_id, product_id = self.obj_ident.split("_")
		goods_id
	end

	def product_id
		_obj_type, goods_id, product_id = self.obj_ident.split("_")
		product_id
	end


	def product
		return  if self.obj_type == "coupon"
		_obj_type, goods_id, product_id = self.obj_ident.split("_")
		@product ||= Ecstore::Product.find_by_product_id(product_id)  if product_id
	end
	

	# def member_id=(id)
	# 	self.member_ident = Digest::MD5.hexdigest(id.to_s)
	# 	super
	# end

	def line_total

		(self.product.price*self.quantity)
  end

  def line_total_bulk

    (self.product.bulk*self.quantity)
  end

  def line_total_wholesale

    (self.product.wholesale*self.quantity)
  end
end