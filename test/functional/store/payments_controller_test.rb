require 'test_helper'

class Store::PaymentsControllerTest < ActionController::TestCase


	test 'alipay notify' do

		post :notify, :id=>'20130606105700',
		                    :adapter=>'alipay',
		                    :notify_time=>Time.now.strftime("%Y-%m-%d %H:%S:%M"),
		                    :notify_type=>'trade_status_sync',
		                    :notify_id=>'70fec0c2730b27528665af4517c27b95',
		                    :sign_type=>"MD5",
		                    :sign=>"",
		                    :out_trade_no=>'',
		                    :subject=>'订单(20130606105700)',
		                    :total_fee=>'1254',
		                    :trade_no=>'2013060613057894',
		                    :trade_status=>'TRADE_FINISHED',
		                    :gmt_payment=>'2013-06-06 20:49:50'

	end
end
