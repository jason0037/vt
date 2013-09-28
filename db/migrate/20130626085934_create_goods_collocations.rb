class CreateGoodsCollocations < ActiveRecord::Migration
  def up
  	create_table :sdb_b2c_goods_collocations,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
  	   t.integer :goods_id
  	   t.text :collocations
  	   t.string :collocation_type, :default=>"goods"
  	   t.timestamps
	end
       add_index :sdb_b2c_goods_collocations, :goods_id, :unique => true
  end

  def down
  	drop_table :sdb_b2c_goods_collocations
  end

  def connection
    @connection = Ecstore::Base.connection
  end
end
