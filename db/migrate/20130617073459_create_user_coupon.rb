class CreateUserCoupon < ActiveRecord::Migration
  def up
    create_table :sdb_imodec_user_coupons,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
      t.integer :member_id
      t.integer :coupon_id
      t.datetime :used_at
      t.integer :used_times
      t.string :coupon_code
    end
  end

  def down
    drop_table :sdb_imodec_user_coupons
  end

  def connection
    @connection = Ecstore::Base.connection
  end
end
