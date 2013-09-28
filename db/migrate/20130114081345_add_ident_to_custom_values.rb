class AddIdentToCustomValues < ActiveRecord::Migration

  def up
    add_column :sdb_b2c_custom_values, :ident, :string
  end

  def down
  	remove_column :sdb_b2c_custom_values,:ident
  end

  def connection
  	@connection = Ecstore::Base.connection
  end

end
