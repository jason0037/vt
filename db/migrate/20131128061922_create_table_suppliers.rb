class CreateTableSuppliers < ActiveRecord::Migration
  # def up
  # 	create_table :sdb_imodec_suppliers,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
  # 		t.string :name
  # 		t.string :desc
  #    t.string :logo
  #   t.string :hots
  #    t.string :url
  # 	end
  # end

  def down
  	drop_table :sdb_imodec_suppliers
  end

  def connection
  	@connection =  Ecstore::Base.connection
  end
end
