#encoding:utf-8
module ModecPay
	class Bill99 < Payment

		@@private_key = 'NIR9FKH68YUGYR3Y'

		def initialize
			super

			self.mer_id = '1002214092801'
			self.private_key = 'NIR9FKH68YUGYR3Y'
			self.action = 'https://www.99bill.com/gateway/recvMerchantInfoAction.htm'
			self.method = 'post'
			self.charset ='utf-8'

			self.sorter = ['inputCharset','bgUrl','version','language','signType',
				               'merchantAcctId','payerName','payerContactType','payerContact',
				               'orderId','orderAmount','orderTime','productName',
				               'productNum','productId','productDesc','ext1',
				               'ext2','payType','bankId','redoFlag','pid','signMsg']
			
		    self.filter = Proc.new { |key,val| val.present? }


			connect_type = '1'

			self.fields['inputCharset'] = '1'
			self.fields['version'] = 'v2.0'
			self.fields['language'] = '1'
			self.fields['signType'] = '1'
			self.fields['merchantAcctId'] = self.mer_id
			self.fields['payerName'] = '快钱支付'
			self.fields['payerContactType'] = '1'
			self.fields['payerContact'] = ''
			self.fields['productNum'] = '1'
			self.fields['productId'] = ''
			self.fields['productDesc'] = ''
			self.fields['ext1'] = ''
			self.fields['ext2'] = ''
			self.fields['payType'] = connect_type == '1' ? '10' : '00'
			self.fields['bankId'] = ''
			self.fields['redoFlag'] = 1
			self.fields['pid'] = ''
		end

		def return_url=(val)
			self.fields['bgUrl'] = val
		end

		def notify_url=(val)
			self.fields['bgUrl'] = val
		end

		def pay_id=(val)
			self.fields['orderId'] = val
		end

		def pay_time=(val)
			val = Time.now unless val.is_a?(Time)
			self.fields['orderTime'] = val.strftime('%Y%m%d%H%M%S')
		end

		def pay_amount=(val)
			self.fields['orderAmount'] = (val * 100).to_i
		end

		def subject=(val)
			self.fields['productName'] = val
		end


		class << self
			def verify_sign(params)
				sign = params.delete('signMsg')

				unsign_hash = {
					"merchantAcctId"=>params["merchantAcctId"],
					"version"=>params["version"],
					"language"=>params["language"],
					"signType"=>params["signType"],
					"payType"=>params["payType"],
					"bankId"=>params["bankId"],
					"orderId"=>params["orderId"],
					"orderTime"=>params["orderTime"],
					"orderAmount"=>params["orderAmount"],
					"dealId"=>params["dealId"],
					"bankDealId"=>params["bankDealId"],
					"dealTime"=>params["dealTime"],
					"payAmount"=>params["payAmount"],
					"fee"=>params["fee"],
					"ext1"=>params["ext1"],
					"ext2"=>params["ext2"],
					"payResult"=>params["payResult"],
					"errCode"=>params["errCode"],
					"key"=>@@private_key
				}

				unsign = unsign_hash.select{ |key,val| val.present? }.collect do |key,val|
					"#{key}=#{val}"
				end.join("&")

				Digest::MD5.hexdigest(unsign).upcase == sign.upcase
			end

			def verify_notify(params,options)

				bill99_redirect_url = options.delete(:bill99_redirect_url)

				if verify_sign(params)
					ModecPay.logger.info "[bill99][#{Time.now}] payment=#{params['orderId']} verify notify successfully."
					
					case params['payResult']
						when '10'
							t_payed = Time.now.to_i
							t_payed = Time.parse(params['dealTime'].to_s).to_i  if params['dealTime'].present?
							result = {  :payment_id=>params['orderId'],
								   :trade_no=>params['dealId'],
								   :status=>'succ',
								   :t_payed=>t_payed,
								   :response => "<result>1</result><redirecturl>#{bill99_redirect_url}?status=success</redirecturl>"
							}
						else
							result = "<result>1</result><redirecturl>#{bill99_redirect_url}?status=failed</redirecturl>"
					end
				else
					result = "<result>1</result><redirecturl>#{bill99_redirect_url}?status=invalid</redirecturl>"
				end

				result
			end

			def verify_return(params,options)
				raise 'not implement'
			end

		end

	     private 

	     def make_sign

			_fields = self.fields.dup
			self.fields = {}   # clear fields
			sorter.each do |key|
				self.fields[key] = _fields.delete(key)
			end
			self.fields.merge!(_fields)  unless _fields.empty?

	     	unsign = self.fields.merge('key'=>self.private_key).select{ |key,val | val.present? }.collect do |key,val|
				"#{key}=#{val}"
			end.join("&")

			self.fields.merge!('signMsg'=>Digest::MD5.hexdigest(unsign).upcase)
	     end

	end
end