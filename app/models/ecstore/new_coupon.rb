#encoding:utf-8
require 'securerandom'
require 'digest'

class Ecstore::NewCoupon < Ecstore::Base
	self.table_name = "sdb_imodec_coupons"
	self.accessible_all_columns

	attr_accessor :current_code

	validates :coupon_prefix, uniqueness: { message: "优惠券号码不能重复" }
	validates_presence_of :name,:message=>"名称不能为空"
	validates_presence_of :desc,:message=>"描述不能为空"

	before_create :set_coupon_key

	def set_coupon_key
		self.coupon_key = SecureRandom.base64(10)
	end

	# before_save :set_coupon_prefix

	# def set_coupon_prefix
	# 	self.coupon_prefix = self.coupon_type + self.coupon_prefix
	# end

	def prefix
		return nil if self.coupon_prefix.blank?
		self.coupon_prefix[1..-1]
	end


	def enable?
	      return false  unless  self.enable
	  	now =  Time.now
	       if self.begin_at.blank? && self.end_at.blank?
	          return true
	       end
	       if self.begin_at.blank? && self.end_at.present?
	           return self.end_at >= now
	       end
	       if self.begin_at.present? && self.end_at.blank?
	          return self.begin_at <= now
	       end
	       return (self.begin_at <= now&& self.end_at >= now)
	end

	def condition_val=(v)
		super(v.to_s)
	end

	def condition_val
		return eval(super)  if super.present?
		nil
	end


	def generate_coupon_code(update_quantity=false)

		return self.coupon_prefix if self.coupon_type == "A"

		no = self.quantity + 1

		key = self.coupon_key
		prefix = self.coupon_prefix
		no = no.to_s(36)
		no = "0" * ( 5 - no.size ) + no
		part = Digest::MD5.hexdigest("#{key}#{no}#{prefix}")[0..4]
		code = "#{prefix}#{part.upcase}#{no.upcase}"
		self.increment!(:quantity) if update_quantity

		code
	end

	def self.check_code(code)
		return false  if code.blank?
		_type = code[0].upcase

		if _type == "A"
			_coupon = self.find_by_coupon_prefix(code)
			return _coupon.present?
		end

		if _type == "B"
			return false if code.size < 11

			_prefix = code[0..-11]
			_coupon = self.find_by_coupon_prefix(_prefix)
			return false  if _coupon.blank?
			
			_no = code[-5..-1].downcase

			_part = Digest::MD5.hexdigest("#{_coupon.coupon_key}#{_no}#{_coupon.coupon_prefix}")[0..4]
			check_code = "#{_coupon.coupon_prefix}#{_part.upcase}#{_no.upcase}"
			return check_code == code.upcase
		end

		false
	end

	def self.check_and_find_by_code(code)

		return nil  unless self.check_code(code)
		_type = code[0].upcase
		if _type == "A"
			_coupon =  self.find_by_coupon_prefix(code)
			_coupon.current_code = code
			return _coupon
		end

		if _type == "B"
			_coupon =  self.find_by_coupon_prefix(code[0..-11])
			_coupon.current_code = code
			return _coupon
		end
	end

	
	def test_condition(line_items = [])
		order_amount  = line_items.collect { |line| line.product.price * line.quantity }.inject(:+).to_i

		cart_goods = line_items.collect { |line| line.good.bn }

		if condition_type == 'order_total_ge_x'
			return true  if order_amount > condition_val
		end

		if condition_type == 'buy_specify_goods'
			return (cart_goods & condition_val).present?
		end
		false
	end


	def pmt_amount(line_items = [])
		return self.action_val.to_i if self.action_type == "order_minus"

		order_amount  = line_items.collect { |line| line.product.price * line.quantity }.inject(:+).to_i
		return order_amount - (order_amount*self.action_val.to_i / 100).round  if self.action_type == "order_discount"
		0 
	end

end