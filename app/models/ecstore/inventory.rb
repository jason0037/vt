class Ecstore::Inventory < Ecstore::Base
	self.table_name = "sdb_imodec_inventorys"

  belongs_to :user,:foreign_key=>"member_id"
  belongs_to :good,:foreign_key=>"goods_id"
  belongs_to :product,:foreign_key=>"product_id"


  self.accessible_all_columns
end