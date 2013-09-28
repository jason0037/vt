class Ecstore::GoodSpecItem < Ecstore::Base
	self.table_name = "sdb_b2c_goods_spec_items"

	belongs_to :good,			:foreign_key=>"goods_id"
	belongs_to :spec_item, 	:foreign_key=>"spec_item_id"

	attr_accessible :spec_value_id, :spec_item_id, :min_value, :max_value,:fixed_value


	default_scope order('id asc')

end