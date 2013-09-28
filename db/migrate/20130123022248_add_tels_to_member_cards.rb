class AddTelsToMemberCards < ActiveRecord::Migration
  def up
    	add_column :sdb_imodec_member_cards, :buyer_tel, :string
    	add_column :sdb_imodec_member_cards, :user_tel, :string

    	add_column :sdb_imodec_member_cards, :buyer_id, :integer
    	add_column :sdb_imodec_member_cards, :user_id, :integer



  end

  def down
  	remove_column :sdb_imodec_member_cards, :buyer_tel
  	remove_column :sdb_imodec_member_cards, :user_tel

  	remove_column :sdb_imodec_member_cards, :buyer_id
  	remove_column :sdb_imodec_member_cards, :user_id
  end


  def connection
  	@connection =  Ecstore::Base.connection
  end

end
