class Ecstore::ShopsGood< Ecstore::Base

  attr_accessible :shop_id, :goods_id, :down_time

  belongs_to :good,:foreign_key=>"goods_id"

end

