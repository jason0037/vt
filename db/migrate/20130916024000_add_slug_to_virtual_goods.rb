class AddSlugToVirtualGoods < ActiveRecord::Migration
  def change
   # add_column :sdb_imodec_virtual_goods, :slug, :string
  end

  def connection
  	@connection =  Ecstore::Base.connection
  end
end
