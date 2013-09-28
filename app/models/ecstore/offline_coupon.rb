#encoding:utf-8
class Ecstore::OfflineCoupon < Ecstore::Base
	self.table_name = "sdb_imodec_offline_coupons"
	self.accessible_all_columns
	belongs_to :brand, :foreign_key=>"brand_id"
	has_many :coupon_downloads


	validates_presence_of :name, :message=>"名称不能为空"
	validates_presence_of :brand_id, :message=>"品牌不能为空"
	validates_presence_of :cover_urls, :message=>"封面不能为空"



	def covers
		self.cover_urls.split /\s+/
	end

	def enable_of(user)
		return true  if user.nil?
		_member_id = user.is_a?(Object) ? user.member_id : user 
		_last = coupon_downloads.where(:member_id=>_member_id).last
		return  true if _last.blank?
		return _last&&(_last.downloaded_at + 30.minutes) < Time.now
	end

	def expired?
		self.end_at&&Time.now > self.end_at
	end

	def start?
		self.begin_at && Time.now < self.begin_at
	end

end