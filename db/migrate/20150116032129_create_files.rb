class CreateFiles < ActiveRecord::Migration
  def change
    create_table :sdb_cheuks_files do |t|
      t.string :name
      t.string :desc
      t.string :file
      t.string :url

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
