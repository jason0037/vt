class CreateSdbCheuksGhistories < ActiveRecord::Migration
  def change
    create_table :sdb_cheuks_ghistories do |t|
      t.integer :goods_id
      t.integer :member_id
      t.string :ip

      t.timestamps
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end

  def connection
    @connection = Ecstore::Base.connection
  end
end
