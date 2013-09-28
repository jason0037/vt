#encoding:utf-8
require 'rjb'
require 'pp'
# require 'active_support'

module ModecPay
	class Icbc < Payment
		

		def initialize
			super
			
			

			self.mer_id = '1001EC23807733'

			self.action = 'https://B2C.icbc.com.cn/servlet/ICBCINBSEBusinessServlet'
			self.method = 'post'
			self.charset ='gbk'

			

			self.fields['interfaceName'] = 'ICBC_PERBANK_B2C'
			self.fields['interfaceVersion'] = '1.0.0.11'

			@tran_data = {}

			@tran_data['interfaceName'] = 'ICBC_PERBANK_B2C'
			@tran_data['interfaceVersion'] = '1.0.0.11'
			
			# orderInfo section
			@order_info = {}
			@order_info['orderDate'] = ''
			@order_info['curType'] = '001'
			@order_info['merID'] = self.mer_id


			# subOrderInfo section
			@sub_order_info = {}
			@sub_order_info['orderid'] = ''
			@sub_order_info['amount'] = ''
			@sub_order_info['installmentTimes'] = '1'
			@sub_order_info['merAcct'] = '1001258219300435028'
			@sub_order_info['goodsID'] = ''
			@sub_order_info['goodsName'] = ''
			@sub_order_info['goodsNum'] = ''
			@sub_order_info['carriageAmt'] = ''

			# custom section
			@custom = {}
			@custom['verifyJoinFlag'] = '0'
			@custom['Language'] = 'ZH_CN'

			# message section
			@message = {}
			@message['creditType'] = '2'
			@message['notifyType'] = 'HS'
			@message['resultType'] = '0'
			@message['merReference'] = '*.i-modec.com'
			@message['merCustomIp'] = ''
			@message['goodsType'] = '1'
			@message['merCustomID'] = ''
			@message['merCustomPhone'] = ''
			@message['goodsAddress'] = ''
			@message['merOrderRemark'] = ''
			@message['merHint'] = ''
			@message['remark1'] = ''
			@message['remark2'] = ''
			@message['merURL'] = ''
			@message['merVAR'] = ''
		end

		# def return_url=(val)
		# 	@message['merHint'] = val
		# end

		def notify_url=(val)
			@message['merURL'] = val
		end

		def pay_id=(val)
			@sub_order_info['orderid'] = val
		end

		def pay_time=(val)
			val = Time.now unless val.is_a?(Time)
			@order_info['orderDate'] = val.strftime("%Y%m%d%H%M%S")
		end

		def pay_amount=(val)
			@sub_order_info['amount'] = (val*100).to_i.to_s
		end

		def subject=(val)
			@sub_order_info['goodsName'] = val
		end

		def installment=(val)
			@sub_order_info['installmentTimes']  = (val || 1).to_s
		end


		class << self

			def verify_notify(params,options)
				@sign = Sign.new
				xml = @sign.decodebase64(params['notifyData'])

				if @sign.verify_sign2(xml,params['signMsg'])
					
					data_hash = Hash.from_xml(xml)
					return false unless data_hash.is_a?(Hash)

					ModecPay.logger.info "[icbc][#{Time.now}] payment=#{data_hash['B2CRes']['orderInfo']['subOrderInfoList']['subOrderInfo']['orderid']} verify notify successfully."

					t_payed = Time.now.to_i
					notify_time = data_hash['B2CRes']['bank']['notifyDate']
					t_payed = Time.parse(notify_time).to_i if  /^\d{14}$/ =~ notify_time

					trade_no = data_hash['B2CRes']['orderInfo']['subOrderInfoList']['subOrderInfo']['tranSerialNo']
					payment_id = data_hash['B2CRes']['orderInfo']['subOrderInfoList']['subOrderInfo']['orderid']

					if data_hash['B2CRes']['bank']['tranStat'] == '1'
						status = 'succ'
						result = {  :payment_id=>payment_id,
						   :trade_no=>trade_no,
						   :status=>status,
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
	     		@order_info.merge!('subOrderInfoList'=>{'subOrderInfo'=>@sub_order_info})
	     		@tran_data.merge!('orderInfo'=>@order_info)
	     		@tran_data.merge!('custom'=>@custom)
	     		@tran_data.merge!('message'=>@message)
	     		tran_data_xml = '<?xml version="1.0" encoding="GBK" standalone="no"?>' + @tran_data.to_xml(:root=>"B2CReq",:skip_instruct=>true,:indent=>0)

	     		@sign = Sign.new  unless @sign
	     		mer_sign_msg = @sign.generate_sign2(tran_data_xml.encode("GBK","UTF-8"))
	     		self.fields['tranData'] = @sign.encodebase64(tran_data_xml.encode("GBK","UTF-8"))
	     		self.fields['merSignMsg'] = mer_sign_msg
	     		self.fields['merCert'] = @sign.encode_cert
	     end


	     class Sign

	     		#  Load jar
	     		def initialize
	     			@lib_jar_path = File.expand_path '../ext/icbc', __FILE__
					libs = ['icbc','InfosecCrypto_Java1_02_JDK14+']
					libs.each do |lib|
						Rjb::add_jar("#{@lib_jar_path}/#{lib}.jar")
					end
					@key_pass = '12345678'

					@return_value =  Rjb::import('cn.com.infosec.icbc.ReturnValue')

					@key_file = "#{@lib_jar_path}/Modec.key"
					@cert_file = "#{@lib_jar_path}/Modec.crt"

					# For change unsigned byte to signed byte
					@signed_byte = Proc.new do |x|
						x = x > 127 ? x - 256 : x
					end
	     		end	

	     		def encode_cert
	     			byte_cert = File.binread(@cert_file).bytes.to_a
	     			@return_value.base64enc(byte_cert).gsub("\n","")
	     		end

	     		def encodebase64(src)
	     			@return_value.base64enc(src)
	     		end


	     		def generate_sign(src)
	     			byte_key = File.binread(@key_file).bytes.map(&@signed_byte).to_a
					byte_src = src.bytes.map(&@signed_byte).to_a
					byte_pass = @key_pass.bytes.map(&@signed_byte).to_a

					tmp_sign = @return_value.sign(byte_src, byte_src.length, byte_key, byte_pass)
					@return_value.base64enc(tmp_sign).gsub("\n","")
	     		end

	     		def generate_sign2(src)
	     			classpath  = "#{@lib_jar_path}:"
					classpath += "#{@lib_jar_path}/icbc.jar:"
					classpath += "#{@lib_jar_path}/InfosecCrypto_Java1_02_JDK14+.jar:"
					classpath += "#{ENV['JAVA_HOME']}/lib:"
					classpath += "#{ENV['JAVA_HOME']}/jre/lib"

					_sign =  `export LANG=zh_CN.GBK && java -classpath #{classpath} icbc_sign #{@key_file} #{@key_pass} "#{src}"`
					
					if matched = _sign.match(/<message>(.+)<\/message>/m)
						return matched[1].gsub("\n","")
	     			else
	     				return nil
	     			end
	     		end

	     		def verify_sign(notify_data,sign)
	     			src  = @return_value.base64dec(notify_data)
	     			byte_src = src.bytes.map(&@signed_byte).to_a
					byte_cert = File.binread(@cert_file).bytes.map(&@signed_byte).to_a

					sign = @return_value.base64dec(sign)
	     			@return_value.verifySign(byte_src,byte_src.length,byte_cert,sign)  == 0
	     		end

	     		# notify_data is xml format
	     		def verify_sign2(notify_data,sign)
	     			classpath  = "#{@lib_jar_path}:"
					classpath += "#{@lib_jar_path}/icbc.jar:"
					classpath += "#{@lib_jar_path}/InfosecCrypto_Java1_02_JDK14+.jar:"
					classpath += "#{ENV['JAVA_HOME']}/lib:"
					classpath += "#{ENV['JAVA_HOME']}/jre/lib"

					ret  =  `export LANG=zh_CN.GBK && java -classpath #{classpath} icbc_verify #{@cert_file} "#{notify_data}" "#{sign}"`

					if matched = ret.match(/<message>(.+)<\/message>/m)
						return matched[1] == '1'
		     		else
		     			return false
		     		end
	     		end

	     		def decodebase64(code)
	     			@return_value.base64dec(code)
	     		end
	     end

	end
end