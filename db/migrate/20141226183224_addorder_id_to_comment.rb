class AddorderIdToComment < ActiveRecord::Migration
  def change
    add_column :sdb_imodec_comments, :order_id, :long
    add_column :sdb_imodec_comments, :degree, :integer
    add_column :sdb_imodec_comments, :title, :string



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
