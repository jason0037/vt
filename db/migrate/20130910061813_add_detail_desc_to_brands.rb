class AddDetailDescToBrands < ActiveRecord::Migration
  def change
    #add_column :sdb_b2c_brand, :detail_desc, :text
  end

  def connection
  	@connection =  Ecstore::Base.connection
  end
end
