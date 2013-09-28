class AddSlugToBrands < ActiveRecord::Migration
  def change
    add_column :sdb_b2c_brand, :slug, :string
    add_index :sdb_b2c_brand, :slug, :unique=>true
  end

  def connection
  	@connection = Ecstore::Base.connection
  end
end
