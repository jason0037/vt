class AddCodesToPromotion < ActiveRecord::Migration
  def change
    add_column :sdb_imodec_promotions, :codes, :long

  end
  def self.down
    raise ActiveRecord::IrreversibleMigration
  end

  def connection
    @connection = Ecstore::Base.connection
  end
end
