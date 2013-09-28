class Ecstore::ReshipItem < Ecstore::Base
	self.table_name = 'sdb_b2c_reship_items'
	self.accessible_all_columns
	
	belongs_to :reship, :foreign_key=>"reship_id"

	belongs_to :product, :foreign_key=>"product_id"

end