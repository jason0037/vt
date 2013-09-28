#encoding:utf-8
require 'digest'
class Ecstore::UserCoupon < Ecstore::Base
	self.table_name = "sdb_imodec_user_coupons"
	self.accessible_all_columns

	belongs_to :new_coupon,:foreign_key=>"coupon_id"

	def coupon_name
		self.new_coupon.name if self.new_coupon
	end

	# def usable?
	# 	return  false unless self.new_coupon
	# 	return valid_code? && used_at.blank? && used_times.to_i == 0 && self.new_coupon.enable?  if self.new_coupon.coupon_type == 'B'
	# 	return valid_code? && self.new_coupon.enable? if self.new_coupon.coupon_type == 'A'
	# end


	def valid_code?
		Ecstore::NewCoupon.check_code(self.coupon_code)
	end

	def can_use?
		return false  unless self.new_coupon
		if self.new_coupon.coupon_type == "A"
			return valid_code?
		end

		if self.new_coupon.coupon_type == "B"
			return valid_code? && used_times.to_i == 0 && used_at.blank?
		end
		false
	end

	def status_text
		state = "有效"
		if self.coupon_code[0] == "B"
			state = "已使用" if self.used_at.present? && self.used_times.to_i > 0
			state = "已过期" unless self.new_coupon.enable?
		end

		if self.coupon_code[0] == "A"
			state = "已过期" unless self.new_coupon.enable? 
		end

		state
	end

end