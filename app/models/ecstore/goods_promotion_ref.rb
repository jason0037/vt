class Ecstore::GoodsPromotionRef < Ecstore::Base
  self.table_name = "sdb_b2c_goods_promotion_ref"
  belongs_to :rule,:foreign_key=>"rule_id"

  self.accessible_all_columns

end