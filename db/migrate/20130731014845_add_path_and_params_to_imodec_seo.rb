class AddPathAndParamsToImodecSeo < ActiveRecord::Migration

  def up
   # add_column :sdb_imodec_seo, :path, :string

    #add_column :sdb_imodec_seo, :params, :string

  end

  def down
  	remove_column :sdb_imodec_seo, :path
  	remove_column :sdb_imodec_seo, :params
  end
  
  def connection
  	@connection  = Ecstore::Base.connection
  end

end
