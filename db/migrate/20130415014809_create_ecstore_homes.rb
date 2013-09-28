class CreateEcstoreHomes < ActiveRecord::Migration
  def change
    create_table :sdb_imodec_homes,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
      t.text :body
      t.string :note
      t.timestamps
    end
  end

  def connection
    	@connection =  Ecstore::Base.connection
  end

end
