class CreateStaticPages < ActiveRecord::Migration
  def up
  	create_table :sdb_imodec_static_pages,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
  	   t.string :title
  	   t.text :body
  	   t.string :slug, :unique=>true,:null=>false
  	   t.timestamps
	end
  end

  def down
  	drop_table :sdb_imodec_static_pages
  end

  def connection
  	@connection = Ecstore::Base.connection
  end

end
