class Ecstore::GoodsCat < Ecstore::Base
  self.table_name = "sdb_b2c_goods_cat"
  self.accessible_all_columns
  attr_accessible :p_order
  attr_accessor :p_order
end
