class AddStatusToGhistory < ActiveRecord::Migration
  def self.up
    change_table :sdb_cheuks_ghistories do |t|
      t.column :status ,"ENUM('0', '1','-1')",:default=>"0"    ###0代表添加成功    -1代表删除的
    end
  end
  def self.down
    raise ActiveRecord::IrreversibleMigration
  end

  def connection
    @connection = Ecstore::Base.connection
  end
end
