class Ecstore::GoodsPromotionRef < Ecstore::Base
  self.table_name = "sdb_b2c_goods_promotion_ref"
  belongs_to :rule,:foreign_key=>"rule_id"
  has_many :cart, :foreign_key =>"ref_id"
  has_many :order_items, :foreign_key =>"ref_id"
  belongs_to :good,:foreign_key=>"goods_id"
  self.accessible_all_columns

end