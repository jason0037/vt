class Ecstore::GoodSpec < Ecstore::Base
	self.table_name = "sdb_b2c_goods_spec_index"

	belongs_to :good,			:foreign_key=>"goods_id"
	belongs_to :spec,			:foreign_key=>"spec_id"
	belongs_to :spec_value, 	:foreign_key=>"spec_value_id"
  belongs_to :product, :foreign_key=>"product_id"

end