class CreateTableCouponDownloads < ActiveRecord::Migration
  def up
  	#create_table :sdb_imodec_coupon_downloads,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
  	#	t.integer :offline_coupon_id
  	#	t.integer :member_id
  	#	t.datetime :downloaded_at
  	#end
  end

  def down
  	drop_table :sdb_imodec_coupon_downloads
  end
  def connection
  	@connection =  Ecstore::Base.connection
  end
end
