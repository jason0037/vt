class CreateCardLogs < ActiveRecord::Migration
 def up
  	create_table :sdb_imodec_card_logs,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
  		t.integer :card_id
  		t.integer :member_id
  		t.string :message
  		
  		t.timestamps
  	end
  end

  def down
  	drop_table :sdb_imodec_card_logs
  end

  def connection
  	@connection =  Ecstore::Base.connection
  end


end
