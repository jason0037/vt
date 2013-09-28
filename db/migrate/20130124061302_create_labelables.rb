class CreateLabelables < ActiveRecord::Migration
  def up
  	create_table :sdb_imodec_labelables,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
  		t.integer :labelable_id
  		t.string :labelable_type
  		t.integer :label_id
  	end
  end

  def down
  	drop_table :sdb_imodec_labelables
  end

  def connection
    @connection =  Ecstore::Base.connection
  end


end
