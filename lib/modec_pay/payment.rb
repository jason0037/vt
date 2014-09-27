#encoding:utf-8
require 'rest-client'
require "uri"
module ModecPay

	class Payment

		attr_accessor :mer_id, :private_key
		attr_accessor :action, :method, :charset
		attr_accessor :fields
		attr_accessor :filter
		
		attr_accessor :return_url, :notify_url
		
		attr_accessor :installment

		#  payment id in db
		attr_accessor :pay_id

		attr_accessor :pay_time, :pay_amount

		# payment subject
		attr_accessor :subject

		# payment description
		attr_accessor :body

    attr_accessor :appid ,:time_stamp,:nonce_str,:sign_type

		# A block pass to sort_by 
		# == Example
		#   payment.sorter = Proc.new { |key,val|  key }
		# Or a Array that contain fields,specify the order
		# == Example
		#   payment.sorter = ['version','lan','sign','_charset']
		#   if extra  in fields,those extra will append to fields
		#   
		#   This is used to order fields for form
		attr_accessor :sorter 

		def initialize
			self.fields = {}
		end

		def html_form
			make_sign

			if sorter.is_a?(Proc)
			    self.fields = Hash.send :[],  self.fields.select{ |key,val|  val.present? }.sort_by(&self.sorter)
			end

			if sorter.is_a?(Array)
				_fields = self.fields.dup
				self.fields = {}
				sorter.each do |key|
					self.fields[key] = _fields.delete(key)
				end
				self.fields.merge!(_fields)  unless _fields.empty?
			end

			_filter = self.filter if self.filter.is_a?(Proc)
			_filter = proc { true }  unless _filter

			form_inputs = self.fields.select(&_filter).collect do |key,val|
				"<input type='hidden' name='#{key}' value='#{val}' />"
			end.join(" ")

			<<-FORM
				<!DOCTYPE html>
				<html>
				<head>
					<meta http-equiv="Content-Type" content="text/html; charset=#{self.charset}">
					<title>Redirecting...</title>
				</head>
				<body>
				<div>Redirecting...</div>
				<form accept-charset="#{self.charset}" action="#{self.action}" method="#{self.method}" id="pay_form">
					#{form_inputs}
				</form>
				<script type="text/javascript">
					window.onload=function(){
						document.getElementById("pay_form").submit();
					}
				</script>
				</body>
				</html>
			FORM
    end

    def html_form_weixin
      make_sign

      if sorter.is_a?(Proc)
        self.fields = Hash.send :[],  self.fields.select{ |key,val|  val.present? }.sort_by(&self.sorter)
      end

      if sorter.is_a?(Array)
        _fields = self.fields.dup
        self.fields = {}
        sorter.each do |key|
          self.fields[key] = _fields.delete(key)
        end
        self.fields.merge!(_fields)  unless _fields.empty?
      end

      _filter = self.filter if self.filter.is_a?(Proc)
      _filter = proc { true }  unless _filter

      form_inputs = self.fields.select(&_filter).collect do |key,val|
        "<input type='hidden' name='#{key}' value='#{val}' />"
      end.join(" ")

      <<-FORM
				<!DOCTYPE html>
				<html>
				<head>
					<meta http-equiv="Content-Type" content="text/html; charset=#{self.charset}">
          <script language="javascript" src="http://res.mail.qq.com/mmr/static/lib/js/jquery.js" type="text/javascript"></script>
          <script language="javascript" src="http://res.mail.qq.com/mmr/static/lib/js/lazyloadv3.js"  type="text/javascript"></script>
					<title>Redirecting...</title>
				</head>
				<body>
				<div>Redirecting...</div>
				<form accept-charset="#{self.charset}" action="#{self.action}" method="#{self.method}" id="pay_form">
					#{form_inputs}
				</form>
				<script type="text/javascript">
					window.onload=function(){
						document.getElementById("pay_form").submit();
					}
				</script>
 <script language="javascript" type="text/javascript">
      function auto_remove(img){
          div=img.parentNode.parentNode;div.parentNode.removeChild(div);
          img.onerror="";
          return true;
      }

      function changefont(fontsize){
          if(fontsize < 1 || fontsize > 4)return;
          $('#content').removeClass().addClass('fontSize' + fontsize);
      }

      // 当微信内置浏览器完成内部初始化后会触发WeixinJSBridgeReady事件。
      document.addEventListener('WeixinJSBridgeReady', function onBridgeReady() {
          //公众号支付
          jQuery('a#getBrandWCPayRequest').click(function(e){
              WeixinJSBridge.invoke('getBrandWCPayRequest',{
                  "appId" : "#{self.fields['appid']}", //公众号名称，由商户传入
                  "timeStamp" : "#{self.fields['time_stamp']}", //时间戳
                  "nonceStr" : "#{self.fields['nonce_str']}", //随机串
                  "package" : "#{self.fields['package']}",//扩展包
                  "signType" : "#{self.fields['sign_type']}", //微信签名方式:1.sha1;2.md5
                  "paySign" : "#{self.fiels['pay_sign']}" //微信签名
              },function(res){

                  if(res.err_msg == "get_brand_wcpay_request:ok" ) {}
                  // 使用以上方式判断前端返回,微信团队郑重提示：res.err_msg将在用户支付成功后返回ok，但并不保证它绝对可靠。
                  //因此微信团队建议，当收到ok返回时，向商户后台询问是否收到交易成功的通知，若收到通知，前端展示交易成功的界面；若此时未收到通知，商户后台主动调用查询订单接口，查询订单的当前状态，并反馈给前端展示相应的界面。
              });

          });

          WeixinJSBridge.log('yo~ ready.');

      }, false)
      if(jQuery){
          jQuery(function(){

              var width = jQuery('body').width() * 0.87;
              jQuery('img').error(function(){
                  var self = jQuery(this);
                  var org = self.attr('data-original1');
                  self.attr("src", org);
                  self.error(function(){
                      auto_remove(this);
                  });
              });
              jQuery('img').each(function(){
                  var self = jQuery(this);
                  var w = self.css('width');
                  var h = self.css('height');
                  w = w.replace('px', '');
                  h = h.replace('px', '');
                  if(w <= width){
                      return;
                  }
                  var new_w = width;
                  var new_h = Math.round(h * width / w);
                  self.css({'width' : new_w + 'px', 'height' : new_h + 'px'});
                  self.parents('div.pic').css({'width' : new_w + 'px', 'height' : new_h + 'px'});
              });
          });
      }
  </script>
</head>
<body>
<div class="WCPay">
  <a id="getBrandWCPayRequest" href="javascript:void(0);"><h1 class="title">点击提交可体验微信支付</h1></a>
</div>
				</body>
				</html>
      FORM
    end

    def get_token
      make_sign

      if sorter.is_a?(Proc)
        self.fields = Hash.send :[],  self.fields.select{ |key,val|  val.present? }.sort_by(&self.sorter)
      end

      if sorter.is_a?(Array)
        _fields = self.fields.dup
        self.fields = {}
        sorter.each do |key|
          self.fields[key] = _fields.delete(key)
        end
        self.fields.merge!(_fields)  unless _fields.empty?
      end

      _filter = self.filter if self.filter.is_a?(Proc)
      _filter = proc { true }  unless _filter

      querystring = self.fields.select(&_filter).collect do |key,val|
        "#{key}=#{val}"
      end.join("&")

      error_message ='取得Token错误'

      res_data= RestClient.get(URI.encode("#{self.action}?#{querystring}"))
      res_data =URI.decode(res_data)
      res_data=res_data.split('&').first.sub('res_data=','')
      #return res_data
      if res_data

        # @@mer_id = '2088411414403176'
        #@@private_key  = 'hzh3bf969beqkqdbohdxocxlwpgr8278'
        #@@seller_account_name='maowei@iotps.com'

        self.sorter = Proc.new { |key,val| key }
        self.filter = Proc.new { |key,val| key.present? }
        #  self.sorter = ['service','req_data','partner','req_id','sec_id', 'format','v']

        request_token = Hash.from_xml(res_data)['direct_trade_create_res']['request_token']
        self.fields['req_data'] = "<auth_and_execute_req><request_token>#{request_token}</request_token></auth_and_execute_req>"
        self.fields['service'] = 'alipay.wap.auth.authAndExecute'
        self.fields['sign'] = make_sign
            #sec_id = 'MD5'
        #partner = ''
        #sign=''
        #format='xml'
        #v = '2 .0'

        querystring = self.fields.select(&_filter).collect do |key,val|
          "#{key}=#{val}"
        end.join("&")

        #return querystring
        RestClient.get(URI.encode("#{self.action}?#{querystring}"))
      #  redirect_to URI.encode("#{self.action}?#{querystring}")

      else
        return error_message
      end


    end

		private 

		#  === Example 
		#  def make_sign
		#      _sign = "secret string"
		#      self.fields['sign'] = _sign
		#  end
		def make_sign
			#warn 'TODO: Add signature to fields'
      return '' if self.fields.blank?
      _sorted = Hash.send :[],  self.fields.select{ |key,val|  val.present? && key != 'sign_type' && key != 'sign' }.sort_by{ |key,val|  key }

      unsign = _sorted.collect{ |key,val| "#{key}=#{val}" }.join("&") + self.private_key
      Digest::MD5.hexdigest(unsign)
		end

	end

end