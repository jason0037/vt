class AddPayStatusToCards < ActiveRecord::Migration
  def up
  	add_column :sdb_imodec_cards, :pay_status, :boolean,:default=>false
  end

  def down
  	remove_column :sdb_imodec_cards, :pay_status
  end

  def connection
    @connection =  Ecstore::Base.connection
  end

end
