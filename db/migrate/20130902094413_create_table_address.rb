class CreateTableAddress < ActiveRecord::Migration
  def up
  #	create_table :sdb_imodec_addresses,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
      #t.string :name
  		#t.float :latitude
  		#t.float :longitude
  		#t.references :addressable, :polymorphic=>true
  	#end
  end

  def down
  	drop_table :sdb_imodec_addresses
  end

  def connection
  	@connection =  Ecstore::Base.connection
  end
end
