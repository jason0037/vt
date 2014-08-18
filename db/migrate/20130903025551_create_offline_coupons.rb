class CreateOfflineCoupons < ActiveRecord::Migration
  def up
  	#create_table :sdb_imodec_offline_coupons,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
  	#	t.string :name
     #         t.string :code
      #        t.float :discount
  		#t.string :sms_text
  		#t.integer :brand_id
  		#t.text :cover_urls
  		#t.boolean :published
       #       t.datetime :begin_at
        #      t.datetime :end_at
         #     t.integer :download_times, :default=>0
  		#t.timestamps
  	#end
  end

  def down
  	drop_table :sdb_imodec_offline_coupons
  end

  def connection
  	@connection =  Ecstore::Base.connection
  end
end
