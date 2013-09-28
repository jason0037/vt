class CreateImodecLabels < ActiveRecord::Migration
  def up
  	create_table :sdb_imodec_labels,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
  		t.string :name
  		t.timestamps
  	end
  end

  def down
  	drop_table :sdb_imodec_labels
  end

  def connection
  	@connection =  Ecstore::Base.connection
  end


end
