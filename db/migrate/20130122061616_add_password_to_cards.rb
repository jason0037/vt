class AddPasswordToCards < ActiveRecord::Migration

  def up
    add_column :sdb_imodec_cards, :password, :string
  end

  def down
  	remove_column :sdb_imodec_cards, :password
  end

  def connection
  	@connection =  Ecstore::Base.connection
  end

end
