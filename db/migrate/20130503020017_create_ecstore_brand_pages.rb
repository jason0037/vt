class CreateEcstoreBrandPages < ActiveRecord::Migration
  def change
    create_table :sdb_b2c_brand_pages,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
      t.integer :brand_id
      t.string :logo_url
      t.text :context

      t.timestamps
    end
  end

   def connection
  	@connection =  Ecstore::Base.connection
  end
end
