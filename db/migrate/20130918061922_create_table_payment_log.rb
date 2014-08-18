class CreateTablePaymentLog < ActiveRecord::Migration
  # def up
  # 	create_table :sdb_imodec_payment_logs,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
  # 		t.string :pay_name
  # 		t.string :payment_id
  #            t.integer :order_id, :limit=>8
  #
  # 		t.string :request_ip
  # 		t.text :request_params
  # 		t.datetime :requested_at
  #
  # 		t.string :return_ip
  # 		t.text :return_params
  # 		t.datetime :returned_at
  #
  # 		t.string :notify_ip
  # 		t.text :notify_params
  # 		t.datetime :notified_at
  #
  #            t.string :result
  # 	end
  # end

  def down
  	drop_table :sdb_imodec_payment_logs
  end

  def connection
  	@connection =  Ecstore::Base.connection
  end
end
