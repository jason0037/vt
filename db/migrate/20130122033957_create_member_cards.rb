class CreateMemberCards < ActiveRecord::Migration
  def up
  	create_table :sdb_imodec_member_cards,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
  		t.integer :member_id
  		t.integer :card_id
  		t.string :bank_name
  		t.string :bank_card_no

  		t.timestamps
  	end
  end

  def down
  	drop_table :sdb_imodec_member_cards
  end

  def connection
  	@connection =  Ecstore::Base.connection
  end

end
