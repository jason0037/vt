class AddUrlToAdverts < ActiveRecord::Migration

  def self.up
    change_table :sdb_cheuks_adverts do |t|
       t.string :url
    end

    end
  def self.down
    raise ActiveRecord::IrreversibleMigration
  end

  def connection
    @connection = Ecstore::Base.connection
  end
end
