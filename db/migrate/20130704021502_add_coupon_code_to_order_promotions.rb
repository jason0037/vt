class AddCouponCodeToOrderPromotions < ActiveRecord::Migration
  def change
    add_column :sdb_imodec_order_promotions, :coupon_code, :string
  end
  def connection
    @connection = Ecstore::Base.connection
  end
end
