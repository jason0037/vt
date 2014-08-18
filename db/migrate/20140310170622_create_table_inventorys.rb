class CreateTableInventorys < ActiveRecord::Migration
  def up
  	# create_table :sdb_imodec_inventorys,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
     # t.integer :member_id
     #  t.integer :goods_id
     #  t.integer :product_id
     #  t.string  :bn
     #  t.string  :barcode
  	# 	t.string  :name
     #  t.decimal :price ,:precision=>10,:scale=>2
  	# 	t.integer :quantity
  	# end
  end

  def down
  drop_table :sdb_imodec_inventorys
  end

  def connection
  	@connection =  Ecstore::Base.connection
  end
end
