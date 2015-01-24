class CreateShopLogs < ActiveRecord::Migration
  def change
    create_table :shop_logs do |t|
      t.integer :shop_id
      t.text :shop_desc
      t.string :shop_ip
      t.integer :datetime

      t.timestamps
    end
  end
  def connection
    @connection = Ecstore::Base.connection
  end
end
