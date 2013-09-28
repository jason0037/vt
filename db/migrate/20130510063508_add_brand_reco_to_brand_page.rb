class AddBrandRecoToBrandPage < ActiveRecord::Migration
  def change
    add_column :sdb_b2c_brand_pages, :brand_reco, :text
  end
  
  def connection
  	@connection = Ecstore::Base.connection
  end

end
