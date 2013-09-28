class AddMemberTypeToMemberCards < ActiveRecord::Migration

  def up
    	add_column :sdb_imodec_member_cards, :member_type, :string #buyer/user
  end

  def down
  	remove_column :sdb_imodec_member_cards, :member_type
  end


  def connection
  	@connection =  Ecstore::Base.connection
  end
end
