class AddFieldsToGoods < ActiveRecord::Migration
  def up
  	add_column :sdb_b2c_goods, :material, :text
  	add_column :sdb_b2c_goods, :mesure, :text
    add_column :sdb_b2c_goods, :try_on, :text

	#expr
  	add_column :sdb_b2c_goods, :softness, :integer
  	add_column :sdb_b2c_goods, :thickness, :integer
  	add_column :sdb_b2c_goods, :elasticity, :integer
  	add_column :sdb_b2c_goods, :fitness, :integer
    add_column :sdb_b2c_goods, :sbn, :string

  end

  def down
  	remove_column :sdb_b2c_goods, :material
  	remove_column :sdb_b2c_goods, :mesure
	#expr
  	remove_column :sdb_b2c_goods, :softness
  	remove_column :sdb_b2c_goods, :thickness
  	remove_column :sdb_b2c_goods, :elasticity
  	remove_column :sdb_b2c_goods, :fitness

  end

  def connection
  	@connection = Ecstore::Base.connection
  end
end
