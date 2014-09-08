class CreateTableCommissions < ActiveRecord::Migration
  def up
  	create_table :sdb_b2c_commissions do |t|
      t.integer :supplier_id
  		t.integer :member_id
  		t.float :commission ,:precision=>10,:scale=>2
      t.string :year_month #佣金所属年月
      t.integer :ctype #0: 推广佣金； 1：平台佣金
      t.integer :status,:default=>0 #0未发放， 1已发放，-1作废
      t.string :openid
      t.integer :orders_num
      t.float :orders_amount ,:precision=>20,:scale=>2
      t.float :rate ,:precision=>5,:scale=>2
      t.timestamps
  	end
  end

  def down
  	drop_table :sdb_b2c_commissions
  end

  def connection
  	@connection =  Ecstore::Base.connection
  end
end
