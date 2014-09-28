#encoding:utf-8
module Store::OrdersHelper

	def ship_day_options
		{      "任意日期"=>"任意日期",
			"仅工作日"=>"仅工作日",
			"仅休息日"=>"仅休息日",
			"指定日期"=>"special"  }
	end

	def ship_time_options
		{     "任意时间段"=>"任意时间段",
			"上午"=>"上午",
			"下午"=>"下午",
			"晚上"=>"晚上"  }
	end


	def payments
		{
      "term"=>{ :name=>"账期支付",:extra=>"与供应商协商"},
      "ips"=>{ :name=>"环迅人民币支付",:extra=>""},
			"bcom"=>{ :name=>"交通银行网上支付", :extra=>"持交通银行卡在线支付可享受订单金额95折优惠" },
			"icbc"=>{ :name=>"工商银行网上支付", :extra=>'申请分期付款 (<span class="highlight">申请信用卡分期付款，超低手续费，月还款无压力！</span>)' },
			"deposit"=>{ :name=>"预存款", :extra=>"" },
			"offline"=>{ :name=>"货到付款", :extra=>link_to("点击查询货到付款配送区域","http://www.zjs.com.cn/WS_Business/WS_Bussiness_CityArea.aspx?id=6",:target=>"_blank").html_safe }, 
			"99bill"=>{ :name=>"其他银行网上支付",:extra=>"" },
			"alipay"=>{ :name=>"支付宝",:extra=>"" },
      "alipaywap"=>{ :name=>"支付宝手机版",:extra=>"" },
      "wxpay"=>{:name=>"微信支付",:extra=>""}
		}
	end
end
