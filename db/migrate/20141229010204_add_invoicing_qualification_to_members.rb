class AddInvoicingQualificationToMembers < ActiveRecord::Migration
  def self.up
    change_table :sdb_b2c_members do |t|
      t.column :invoicing_qualification ,"ENUM('有', '无')",:default=>"无"
    end
  end
  def self.down
    raise ActiveRecord::IrreversibleMigration
  end

  def connection
    @connection = Ecstore::Base.connection
  end
end
