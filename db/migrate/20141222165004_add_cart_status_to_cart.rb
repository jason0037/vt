class AddCartStatusToCart < ActiveRecord::Migration
  def self.up
    change_table :sdb_b2c_cart_objects do |t|
      t.column :cart_status ,"ENUM('0', '1','-1')",:default=>"0"    ###0代表添加成功 1代表已经购买   -1代表添加后被删除的
    end
  end
  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end

  def connection
    @connection = Ecstore::Base.connection
  end
end
