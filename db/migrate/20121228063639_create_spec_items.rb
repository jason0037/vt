class CreateSpecItems < ActiveRecord::Migration
  def up
  	create_table :sdb_b2c_spec_items,:options => 'ENGINE=MyISAM DEFAULT CHARSET=utf8' do |t|
  		t.string :name
  		t.string :item_type, :default=>'fixed'  #fixed/scope
  	end
  end

  def down
  	drop_table :sdb_b2c_spec_items
  end

  def connection
  	@connection = Ecstore::Base.connection
  end

end
