class Ecstore::MemberCoupon < Ecstore::Base
	self.table_name = "sdb_b2c_member_coupon"
	self.primary_key = :memc_code

	belongs_to :coupon,:foreign_key=>"cpns_id"

	attr_accessible :memc_enabled

	def used?
		self.memc_used_times > 0
	end

	def coupon_name
		self.coupon.cpns_name
	end
end