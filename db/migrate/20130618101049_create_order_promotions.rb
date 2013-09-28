class CreateOrderPromotions < ActiveRecord::Migration
  def up
    create_table :sdb_imodec_order_promotions,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
      t.integer :order_id,:limit=>8
      t.integer :pmt_id
      t.string :pmt_type
      t.decimal :pmt_amount, :precision=>10, :scale=>3, :default => 0.000
      t.string :pmt_name
      t.string :pmt_desc
      t.integer :user_coupon_id

      t.timestamps
    end
  end

  def down
    drop_table :sdb_imodec_order_promotions
  end

  def connection
    @connection = Ecstore::Base.connection
  end
end
