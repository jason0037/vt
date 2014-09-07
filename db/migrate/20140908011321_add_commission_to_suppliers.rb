class AddCommissionToSuppliers < ActiveRecord::Migration

   def change
     add_column :sdb_imodec_suppliers, :commission_platform, :decimal,:precision=>10,:scale=>2
     add_column :sdb_imodec_suppliers, :commission_promotion, :decimal,:precision=>10,:scale=>2, :default => 0.01
     add_column :sdb_imodec_suppliers, :commission_confirm_days, :int,:default=>14
   end
  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end

   def connection
     @connection = Ecstore::Base.connection
   end
end
