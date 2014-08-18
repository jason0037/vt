class AddLayoutToStaticPages < ActiveRecord::Migration
  def up
   # add_column :sdb_imodec_static_pages, :layout, :string
    Ecstore::Page.update_all :layout=>"standard"
  end

  def down
   #  remove_column :sdb_imodec_static_pages, :layout
  end

  def connection
  	@connection = Ecstore::Base.connection
  end
  
end
