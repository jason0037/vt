
class Ecstore::OrderDining < Ecstore::Base
  self.table_name = "sdb_b2c_order_dinings"

  belongs_to :account,:foreign_key=> "account_id"
  belongs_to :supplier,:foreign_key => "supplier_id"

  attr_accessible :account_id, :dining_content, :dining_count, :dining_time, :dining_use, :phone, :suppliers_id
end
