class CreateComments < ActiveRecord::Migration
  def up
  	create_table :sdb_imodec_comments,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
  	   t.integer :member_id
  	   t.text :content
  	   t.integer :commentable_id
  	   t.string :commentable_type
  	   t.timestamps
	end
  end

  def down
  	drop_table :sdb_imodec_comments
  end

  def connection
    @connection = Ecstore::Base.connection
  end

end
