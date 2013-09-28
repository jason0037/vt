class Ecstore::CustomValue < Ecstore::Base
	self.table_name  = "sdb_b2c_custom_values"
	attr_accessible :order_id,:member_id,:product_id,:spec_item_id,:name,:value,:ident
end