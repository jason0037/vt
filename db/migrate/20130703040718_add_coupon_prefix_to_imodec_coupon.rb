class AddCouponPrefixToImodecCoupon < ActiveRecord::Migration
  def change
    add_column :sdb_imodec_coupons, :coupon_prefix, :string
  end

  def connection
    @connection = Ecstore::Base.connection
  end
  
end
