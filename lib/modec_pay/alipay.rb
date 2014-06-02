#encoding:utf-8
module ModecPay
	class Alipay < Payment

		#@@mer_id = '2088701875473608'
		#@@private_key  = 'x5cynpqbifj5uauqj1nx8cd79o3no4vy'

    @@mer_id = '2088411414403176'
    @@private_key  = 'hzh3bf969beqkqdbohdxocxlwpgr8278'

		def initialize
			super


      self.mer_id =  @@mer_id
      self.private_key = @@private_key

			self.action = 'https://mapi.alipay.com/gateway.do' 
			# self.action = 'https://www.alipay.com/cooperate/gateway.do'
			self.method = 'get'
			self.charset ='utf-8'


			self.sorter = Proc.new { |key,val| key }
			self.filter = Proc.new { |key,val| key.present? }

			self.fields['sign_type'] ='MD5'
			self.fields['service'] =  'create_direct_pay_by_user'
			self.fields['partner'] = self.mer_id
			self.fields['_input_charset'] = 'utf-8'
			self.fields['payment_type'] = '1'
			self.fields['seller_id'] = @@mer_id

		end
		
		def return_url=(val)
			self.fields['return_url'] = val
		end

		def notify_url=(val)
			self.fields['notify_url'] = val
		end

		def pay_id=(val)
			self.fields['out_trade_no'] = val
		end

		def pay_time=(val)
			super
		end

		def pay_amount=(val)
			self.fields['total_fee'] = val
		end

		def subject=(val)
			self.fields['subject'] = val
		end


		class <<  self
			def verify_sign(params)
				sign = params['sign']
				
				_sorted_hash = Hash.send :[],  params.select{ |key,val| val.present? && key != 'sign' && key != 'sign_type' }.sort_by{ |key,val|  key }

				unsign = _sorted_hash.collect do |key,val|
					"#{key}=#{val}"
				end.join("&") + @@private_key

				Digest::MD5.hexdigest(unsign) == sign
			end

			def verify_notify(params,options)
				if verify_sign(params)
					
					ModecPay.logger.info "[alipay][#{Time.now}] payment=#{params['out_trade_no']} verify notify successfully."

					case params['trade_status']
						when 'TRADE_FINISHED','TRADE_SUCCESS'
							t_payed = Time.now.to_i
							t_payed = Time.parse(params['gmt_payment']).to_i  if params['gmt_payment'].present?
							result = {  :payment_id=>params['out_trade_no'],
								   :trade_no=>params['trade_no'],
								   :status=>'succ',
								   :t_payed=>t_payed,
								   :response => 'success'
							}
						else
							result =  false
					end
				else
					result = false
				end
				result
			end


			def verify_return(params,options)
				is_success = params['is_success']
				if verify_sign(params)
					ModecPay.logger.info "[alipay][#{Time.now}] verify return successfully."
					case params['trade_status']
						when 'TRADE_FINISHED','TRADE_SUCCESS'
							t_payed = Time.now
							result = {  :payment_id=>params['out_trade_no'],
								   :trade_no=>params['trade_no']
							}
							if is_success == "T"
								result.merge!(:status=>'succ',:response => 'success', :t_payed=>t_payed)
							else
								result =  false
							end
						else
							result =  false
					end
				else
					result = false
				end

				result
			end
		end

	     private 

	     def make_sign
	     		return '' if self.fields.blank?
	     		_sorted = Hash.send :[],  self.fields.select{ |key,val|  val.present? && key != 'sign_type' && key != 'sign' }.sort_by{ |key,val|  key }

	     		unsign = _sorted.collect{ |key,val| "#{key}=#{val}" }.join("&") + self.private_key
	     		self.fields['sign'] = Digest::MD5.hexdigest(unsign)
	     end

	end
end