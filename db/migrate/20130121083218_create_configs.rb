class CreateConfigs < ActiveRecord::Migration
  def up
    create_table :sdb_imodec_configs,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
      t.string :name
      t.string :key
      t.string :value
    end
  end

  def down
    drop_table :sdb_imodec_configs
  end

  def connection
    @connection =  Ecstore::Base.connection
  end
end
