class ChangeSlugToStaticPages < ActiveRecord::Migration

  def change
  	remove_column :sdb_imodec_static_pages, :slug
  	add_column :sdb_imodec_static_pages, :slug, :string
  end

  def connection
  	@connection = Ecstore::Base.connection
  end

end
