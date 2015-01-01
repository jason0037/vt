class AddGoodsidToPromotion < ActiveRecord::Migration
  def change
    add_column :sdb_imodec_promotions, :goodsid, :long

  end
  def self.down
    raise ActiveRecord::IrreversibleMigration
  end

  def connection
    @connection = Ecstore::Base.connection
  end
end
