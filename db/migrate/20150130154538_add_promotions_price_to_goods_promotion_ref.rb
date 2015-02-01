class AddPromotionsPriceToGoodsPromotionRef < ActiveRecord::Migration
  def self.up
    change_table :sdb_b2c_goods_promotion_ref do |t|
        t.integer :promotionsprice   ###
         t.integer :count ,:default=>"0"  ###购买次数
        t.integer :persons , :default=>"0"
    end
  end

  def connection
    @connection = Ecstore::Base.connection
  end
end
