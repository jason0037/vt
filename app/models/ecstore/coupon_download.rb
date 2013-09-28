class Ecstore::CouponDownload < Ecstore::Base
	self.table_name = "sdb_imodec_coupon_downloads"

	self.accessible_all_columns

	belongs_to :user,:foreign_key => "member_id"
	belongs_to :offline_coupon


	

end