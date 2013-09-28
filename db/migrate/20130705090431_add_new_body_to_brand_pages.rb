class AddNewBodyToBrandPages < ActiveRecord::Migration
  def change
    add_column :sdb_b2c_brand_pages, :new_body, :text
  end

  def connection
  	@connection = Ecstore::Base.connection
  end
  
end
