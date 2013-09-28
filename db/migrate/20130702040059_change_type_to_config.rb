class ChangeTypeToConfig < ActiveRecord::Migration
 def change
    change_column :sdb_imodec_configs, :value, :text
  end
  
  def connection
  	@connection =  Ecstore::Base.connection
  end
end
