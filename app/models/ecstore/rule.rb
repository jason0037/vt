class Ecstore::Rule < Ecstore::Base
  self.table_name = "sdb_b2c_sales_rule_goods"

  belongs_to :good, :foreign_key=>"goods_id"
  self.accessible_all_columns
end