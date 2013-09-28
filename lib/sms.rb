#encoding:utf-8
require 'faraday'
module Sms

	ERR_MSG = {
		 -1 => "余额不足",
		 -2 => "帐户和密码错误",	
		 -3 => "连接服务商失败",	
		 -4 => "超时",
		 -5 => "其他错误",
		 -6 => "短信内容为空",
		 -7 => "目标号码为空",
		 -8 => "用户通道设置不对，应该设置三个通道",
		 -9 => "捕获未知异常",
		 :success=>"发送手机验证码成功",
		 :error=>"发送手机验证码失败"
	}
	
	def self.send(mobile,text,options={})
		account = options.delete(:account) || 'i-modec'
		password = options.delete(:password) || '888333'

		@conn ||= Faraday.new(:url => 'http://114.80.208.222:8080/NOSmsPlatform/server/SMServer.htm') do |faraday|
			  faraday.request  :url_encoded
			  faraday.response :logger
			  faraday.adapter  Faraday.default_adapter
		end
		res = @conn.get do |req|
			req.params['types'] = 'send'
			req.params['account'] = account
			req.params['password'] = password
			req.params['destmobile'] = mobile
			req.params['msgText'] = text
		end
		if /^-?\d+$/ =~ res.body.strip
			ret = res.body.strip.to_i
			if ret < 0
				raise ERR_MSG[ret]
			else
				return true
			end
		else
			raise ERR_MSG[:error]
		end
	end
end
 