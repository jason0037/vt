class AddSentSmsAtToMembers < ActiveRecord::Migration
  def up
    	add_column :sdb_b2c_members, :sent_sms_at, :datetime
  end

  def down
  	remove_column :sdb_b2c_members, :sent_sms_at
  end

  def connection
  	@connection =  Ecstore::Base.connection
  end
end
