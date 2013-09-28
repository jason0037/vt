class Ecstore::GoodCollocation < Ecstore::Base
  self.table_name = "sdb_b2c_goods_collocations"

  belongs_to :good, :foreign_key=>"goods_id"

  serialize :collocations, Array

  self.accessible_all_columns
end
