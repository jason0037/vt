class CreateSdbPamAuthExt < ActiveRecord::Migration
  def up
  	create_table :sdb_pam_auth_ext,:options => 'ENGINE=MyISAM DEFAULT CHARSET=utf8' do |t|
  		t.integer :account_id
  		t.string :access_token
  		t.integer :expires_in
  		t.integer :expires_at
  		t.string :uid
  		t.string :provider
  		
  		t.timestamps
  	end
  end

  def down
  	drop_table :sdb_pam_auth_ext
  end

  def connection
    @connection = Ecstore::Base.connection
  end
  
end

