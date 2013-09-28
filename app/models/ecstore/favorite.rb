class Ecstore::Favorite < Ecstore::Base
	self.table_name = "sdb_b2c_member_goods"
	default_scope where(:type=>"fav")
	self.primary_key = "gnotify_id"
	attr_accessible :goods_id,:member_id,:status,:create_time,:disabled,:type,:object_type

	belongs_to :good, :foreign_key=>"goods_id"

	self.inheritance_column = nil
end