class CreateTagExt < ActiveRecord::Migration
  def up
  	create_table :sdb_desktop_tag_ext,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
  		t.integer :tag_id
  		t.string :tag_name
  		t.datetime :deadline
  		t.string :cover_url
             t.string :issue_no
  	end
  end

  def down
  	drop_table :sdb_desktop_tag_ext
  end

  def connection
  	@connection =  Ecstore::Base.connection
  end

end
