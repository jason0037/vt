class CreateExpresses < ActiveRecord::Migration
  def change
    create_table :sdb_b2c_expresses do |t|
      t.string :departure
      t.string :arrival
      t.float :unit_price
      t.float :total

      t.timestamps
    end
  end

  def connection
    @connection =  Ecstore::Base.connection
  end
end
