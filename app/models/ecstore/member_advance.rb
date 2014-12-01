class Ecstore::MemberAdvance < Ecstore::Base
	self.table_name = "sdb_b2c_member_advance"
	attr_accessible :member_id,:order_id, :money, :message, :mtime, :memo, :import_money, :explode_money, :member_advance, :shop_advance, :disabled
	belongs_to :user,:foreign_key=>"member_id"


	def logged_at
		Time.at(mtime).strftime("%Y-%m-%d %H:%M:%S")
	end
end