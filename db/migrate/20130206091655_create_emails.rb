class CreateEmails < ActiveRecord::Migration
  def up
  	create_table :sdb_imodec_emails,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
  		t.string :addr
  		t.datetime :sent_at
  		t.timestamps
  	end
  end

  def down
  	drop_table :sdb_imodec_emails
  end

  def connection
    @connection =  Ecstore::Base.connection
  end

end
