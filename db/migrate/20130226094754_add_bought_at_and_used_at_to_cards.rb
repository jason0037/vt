class AddBoughtAtAndUsedAtToCards < ActiveRecord::Migration
  def up
    	add_column :sdb_imodec_cards, :sold_at, :datetime
    	add_column :sdb_imodec_cards, :used_at, :datetime
  end

  def down
  	remove_column :sdb_imodec_cards, :sold_at
  	remove_column :sdb_imodec_cards, :used_at
  end


  def connection
  	@connection =  Ecstore::Base.connection
  end
end
