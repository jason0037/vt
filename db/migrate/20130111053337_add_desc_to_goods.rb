class AddDescToGoods < ActiveRecord::Migration
	
  def up
    add_column :sdb_b2c_goods, :desc, :text
  end

  def down
  	remove_column :sdb_b2c_goods,:desc
  end

  def connection
  	@connection = Ecstore::Base.connection
  end

end
