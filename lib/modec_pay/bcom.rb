#encoding:utf-8
require 'rjb'
require 'pp'

module ModecPay
	class Bcom < Payment
		
		def initialize
			super
			

			self.mer_id = '301310053119675'
			self.action = 'https://pay.95559.com.cn/netpay/MerPayB2C'
			
			# self.action = 'https://pbanktest.95559.com.cn/netpay/MerPayB2C' # test

			self.method = 'post'
			self.charset ='gbk'

			self.sorter = ['interfaceVersion','merID','orderid','orderDate',
				               'orderTime','tranType','amount','curType',
				               'orderContent','orderMono','phdFlag','notifyType',
				               'merURL','goodsURL','jumpSeconds','payBatchNo',
				               'proxyMerName','proxyMerType','proxyMerCredentials','netType',
				               'merSignMsg']

			self.fields['interfaceVersion'] = '1.0.0.0'
			self.fields['merID'] = self.mer_id
			self.fields['tranType'] =0
			self.fields['curType'] = 'CNY'
			self.fields['orderMono'] = ""
			self.fields['phdFlag'] = 1
			self.fields['notifyType'] = 1
			self.fields['jumpSeconds'] ="5"
			self.fields['payBatchNo'] = ""
			self.fields['proxyMerName'] =""
			self.fields['proxyMerType'] =""
			self.fields['proxyMerCredentials'] = ""
			self.fields['netType'] = 0

		end

		def return_url=(val)
			self.fields['goodsURL'] = val
		end

		def notify_url=(val)
			self.fields['merURL'] = val
		end

		def pay_id=(val)
			self.fields['orderid'] = val
		end

		def pay_time=(val)
			val = Time.now unless val.is_a?(Time)
			self.fields['orderDate'] = val.strftime("%Y%m%d")
			self.fields['orderTime'] = val.strftime("%H%M%S")
		end

		def pay_amount=(val)
			self.fields['amount'] = val
		end

		def subject=(val)
			self.fields['orderContent'] = val
		end


		class << self

			def verify_notify(params,options)
				@sign = Sign.new
				
				if @sign.verify_sign(params['notifyMsg'])

					tran_arr = params['notifyMsg'].split("|")

					ModecPay.logger.info "[bcom][#{Time.now}] payment=#{tran_arr[1]} verify notify successfully."

					t_payed = Time.now.to_i
					trade_time = tran_arr[6] + tran_arr[7]
					t_payed = Time.parse(trade_time).to_i  if trade_time.present?

					if tran_arr[9] == '1'
						result = {  :payment_id=>tran_arr[1],
						   :trade_no=>tran_arr[8],
						   :status=>'succ',
						   :t_payed=>t_payed,
						   :response => 'success'
						}
					else
						result = false
					end
				else
					result = false
				end

				result
			end

			def verify_return(params,options)
				verify_notify(params,options)
			end
		end

	     private 

	     def make_sign
	     	_fields = self.fields.dup
			self.fields = {}   # clear fields
			self.sorter.each do |key|
				self.fields[key] = _fields.delete(key) if _fields.has_key?(key)
			end
			self.fields.merge!(_fields)  unless _fields.empty?

			unsign =  self.fields.collect { |key,val| val }.join("|")

			self.fields['merSignMsg'] = Sign.new.generate_sign(unsign)
	     end


	     class Sign

	     		#  Load jar
	     		def initialize
	     			@lib_jar_path = File.expand_path '../ext/bcom', __FILE__
					libs = ['jsse','ISFJ_v2_0_119_2_BAISC_JDK14','bocomm-netsign1.8','bocommapi1.2.1']
					libs.each do |lib|
						Rjb::add_jar("#{@lib_jar_path}/#{lib}.jar")
					end

					client =  Rjb::import('com.bocom.netpay.b2cAPI.BOCOMB2CClient').new
					ret = client.initialize("#{@lib_jar_path}/B2CMerchant.xml")

					raise "Initialize failed, #{ client.getLastErr }" if ret != 0
					
					@net_server =  Rjb::import('com.bocom.netpay.b2cAPI.NetSignServer').new
					@setting = Rjb::import('com.bocom.netpay.b2cAPI.BOCOMSetting')
					@cert_dn = @setting.MerchantCertDN
	     		end	


	     		def generate_sign(source)
	     			@net_server.NSSetPlainText(source.encode("GBK"))
	     			_sign = @net_server.NSDetachedSign(@cert_dn)
	     			raise "make signature failed" if @net_server.getLastErrnum < 0
	     			_sign 
	     		end

	     		def verify_sign(notify_msg)
	     			sign = notify_msg.split("|").last.encode("GBK")
	     			last_index = notify_msg.rindex("|")
	     			src = notify_msg[0..last_index].encode("GBK")
	     			@net_server.NSDetachedVerify(sign,src)
	     			return @net_server.getLastErrnum >= 0
	     		end
	     end

	end
end