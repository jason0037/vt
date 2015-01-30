class AddPromotionsPriceToGoodsPromotionRef < ActiveRecord::Migration
  def self.up
    change_table :sdb_b2c_goods_promotion_ref do |t|
      t.integer :promotionsprice   ###

    end
  end

  def connection
    @connection = Ecstore::Base.connection
  end
end
