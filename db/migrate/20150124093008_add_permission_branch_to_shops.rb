class AddPermissionBranchToShops < ActiveRecord::Migration
  def self.up
    change_table :shops do |t|
      t.column :permission_branch ,"ENUM('-2','-1','0','1')",:default=>"-2"   #-2是默认，-1是有资格开，0是申请，1是批准


    end
  end

  def connection
    @connection = Ecstore::Base.connection
  end

end
