class AddFieldsToPromotions < ActiveRecord::Migration
  def up
    add_column :sdb_imodec_promotions, :field_name,:string
    add_column :sdb_imodec_promotions, :in_or_not,:string
    add_column :sdb_imodec_promotions, :field_vals, :text
  end

  def down
  	remove_column :sdb_imodec_promotions, :field_name
    	remove_column :sdb_imodec_promotions, :in_or_not
    	remove_column :sdb_imodec_promotions, :field_vals
  end
  
  def connection
    @connection = Ecstore::Base.connection
  end

end
