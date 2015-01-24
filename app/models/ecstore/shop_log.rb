#encoding:utf-8
class Ecstore::ShopLog< Ecstore::Base

    self.accessible_all_columns
    belongs_to :shop,:foreign_key=>"shop_id"

end
