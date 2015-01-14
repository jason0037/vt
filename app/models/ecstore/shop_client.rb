class Ecstore::ShopClient< Ecstore::Base

  self.accessible_all_columns

  belongs_to :shop,:foreign_key=>"shop_id"
  belongs_to :user,:foreign_key=>"member_id"

end

