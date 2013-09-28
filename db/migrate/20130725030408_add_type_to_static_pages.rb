class AddTypeToStaticPages < ActiveRecord::Migration
  def change
    add_column :sdb_imodec_static_pages, :type, :string
  end
  def connection
  	@connection = Ecstore::Base.connection
  end
end
