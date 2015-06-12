#encoding:utf-8
module Admin::OrdersHelper
	def payment_options
		{
#		"bcom"=>"交通银行在线支付",
#		"icbc"=>"工商银行在线支付",		
#		"99bill"=>"快钱网上支付",
		"deposit"=>"预存款支付",
		"offline"=>"货到付款",
		"alipay"=>"支付宝支付",
		"wxpay"=>"微信支付",
		"alipaywap"=>"支付宝手机版",
    	"ips"=>"环迅人民币支付"}
	end
end
