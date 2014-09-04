class AddSupplierIdAndCategoryToStaticPages < ActiveRecord::Migration

   def self.up
     change_table :sdb_imodec_static_pages do |t|
       t.string :category
       t.integer :supplier_id
     end
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
