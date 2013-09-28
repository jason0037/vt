class Ecstore::GoodTypeSpec < Ecstore::Base
  self.table_name = "sdb_b2c_goods_type_spec"

  belongs_to :good_type, :foreign_key=>"type_id"
  belongs_to :spec,:foreign_key=>"spec_id"
  
end
