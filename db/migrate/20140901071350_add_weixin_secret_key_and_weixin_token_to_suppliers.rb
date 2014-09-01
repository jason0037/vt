class AddWeixinSecretKeyAndWeixinTokenToSuppliers < ActiveRecord::Migration

   def self.up
     change_table :sdb_imodec_suppliers do |t|
       t.string :weixin_secret_key
       t.string :weixin_token
     end
     add_index :sdb_imodec_suppliers, :weixin_secret_key
     add_index :sdb_imodec_suppliers, :weixin_token
   end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end
end
