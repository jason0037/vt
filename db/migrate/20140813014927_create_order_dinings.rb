class CreateOrderDinings < ActiveRecord::Migration
  def change
    create_table :sdb_b2c_order_dinings do |t|
      t.integer :account_id
      t.integer :suppliers_id
      t.string :dining_use
      t.integer :dining_time
      t.integer :dining_count
      t.string :dining_content
      t.integer :phone

      t.timestamps
    end
  end


  def connection
    @connection =  Ecstore::Base.connection
  end
end
