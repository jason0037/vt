class ChangeAdminCards < ActiveRecord::Migration
  def change
  	change_column :sdb_imodec_cards,:sale_status,:boolean
  	change_column :sdb_imodec_cards,:use_status,:boolean
  	remove_column :sdb_imodec_cards,:user_tel
  	remove_column :sdb_imodec_cards,:buyer_tel
  end

  def connection
  	@connection =  Ecstore::Base.connection
  end

end
