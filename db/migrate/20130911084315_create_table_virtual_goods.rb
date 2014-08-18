class CreateTableVirtualGoods < ActiveRecord::Migration
 def up
  	#create_table :sdb_imodec_virtual_goods,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
  	#	t.integer :brand_id
  	#	t.integer :cat_id
  	#	t.string :bn
  	#	t.string :name
  	#	t.decimal  :price, :scale=>3
  	#	t.boolean :marketable,:defualt=>false
  	#	t.integer :uptime
  	#	t.integer :downtime
  	#	t.text :desc
     #         t.timestamps
  	#end
  end

  def down
  	drop_table :sdb_imodec_virtual_goods
  end
  def connection
  	@connection =  Ecstore::Base.connection
  end
end
