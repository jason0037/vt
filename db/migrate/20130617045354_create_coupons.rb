class CreateCoupons < ActiveRecord::Migration
  def up
    create_table :sdb_imodec_coupons,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
      t.string :name
      t.string :desc
      t.integer :priority
      t.datetime :begin_at
      t.datetime :end_at
      t.boolean :exclusive
      t.boolean :enable
      t.string :coupon_type
      t.string :coupon_key
      t.integer :quantity, :default => 0

      t.string :condition_type
      t.text :condition_val
      t.string :action_type
      t.string :action_val

      t.timestamps
    end
  end

  def down
    drop_table :sdb_imodec_coupons
  end

  def connection
    @connection = Ecstore::Base.connection
  end

end
