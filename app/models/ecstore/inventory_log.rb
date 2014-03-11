class Ecstore::InventoryLog < Ecstore::Base
	self.table_name = "sdb_imodec_inventory_log"

  belongs_to :user,:foreign_key=>"member_id"
  belongs_to :good,:foreign_key=>"goods_id"
  belongs_to :product, :foreign_key=>"product_id"
  belongs_to :order_item, :foreign_key=>"order_items_id"
  belongs_to :order,:foreign_key=>"order_id"

  self.accessible_all_columns
end