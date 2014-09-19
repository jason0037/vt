#encoding:utf-8
module ModecPay
	class Alipaywap < Payment

		#@@mer_id = '2088701875473608'
		#@@private_key  = 'x5cynpqbifj5uauqj1nx8cd79o3no4vy'

    @@mer_id = '2088411414403176'
    @@private_key  = 'hzh3bf969beqkqdbohdxocxlwpgr8278'
    @@seller_account_name='maowei@iotps.com'

		def initialize
			super

      self.private_key = @@private_key

			self.method = 'get'
			self.charset ='utf-8'
      self.action ='http://wappaygw.alipay.com/service/rest.htm'
      #self.action='http://www.trade-v.com/payments/debug'

			self.sorter = Proc.new { |key,val| key }
			self.filter = Proc.new { |key,val| key.present? }
    #  self.sorter = ['service','req_data','partner','req_id','sec_id', 'format','v']

      self.fields['service'] =  'alipay.wap.trade.create.direct'
      self.fields['format']='xml'
      self.fields['v']='2.0'
      self.fields['partner'] = @@mer_id
			self.fields['sec_id'] ='MD5' #'0001' #=>RSA

      @member_id ='userid'  #@user.member_id #买家在商户系统的唯一标识。可空
      @merchant_url = 'http://www.trade-v.com/m' #操作中断返回地址,可空
      @pay_expire = 21600 #交易自动关闭时间，单位为 分钟。 默认值 21600（即 15 天），可空

    end

    def subject=(val)
      @subject = val
    end
		
		def return_url=(val)
			@call_back_url = val
		end

		def notify_url=(val)
			@notify_url = val #可空
		end

		def pay_id=(val)
			@out_trade_no = val
      self.fields['req_id']= val
		end

		def pay_time=(val)
			super
		end

		def pay_amount=(val)
			@total_fee = format("%0.2f",  val)
      self.fields['req_data']="<direct_trade_create_req><subject>#{@out_trade_no}</subject><out_trade_no>#{@out_trade_no}</out_trade_no><total_fee>#{@total_fee}</total_fee><seller_account_name>#{@@seller_account_name}</seller_account_name><call_back_url>#{@call_back_url}</call_back_url><notify_url>#{@notify_url}</notify_url><out_user>#{@out_user}</out_user><merchant_url>#{@merchant_url}</merchant_url><pay_expire>#{@pay_expire}</pay_expire></direct_trade_create_req>"
    end

		class <<  self
			def verify_sign(params)
				sign = params['sign']
				
			#	_sorted_hash = Hash.send :[],  params.select{ |key,val| val.present? && key != 'sign' && key != 'sign_type' }.sort_by{ |key,val|  key }

				#unsign = _sorted_hash.collect do |key,val| 	"#{key}=#{val}" end.join("&") + @@private_key #self.private_key

        unsign_hash =Hash.send :[],  params.select{ |key,val| val.present? && key != 'sign' && key != 'sign_type' }
        unsign = unsign_hash.collect do |key,val| 	"#{key}=#{val}" end.join("&") + @@private_key #self.private_key
				Digest::MD5.hexdigest(unsign) == sign
			end

			def verify_notify(params,options)
				if verify_sign(params)
					
					ModecPay.logger.info "[alipaywap][#{Time.now}] payment=#{params['out_trade_no']} verify notify successfully."

          case params['result']
            when 'success'
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
				if verify_sign(params)
					ModecPay.logger.info "[alipaywap][#{Time.now}] verify return successfully."
					case params['result']
						when 'success'
							t_payed = Time.now
							result = {  :payment_id=>params['out_trade_no'],
								   :trade_no=>params['trade_no']
							}
							result.merge!(:status=>'succ',:response => 'success', :t_payed=>t_payed)

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
          #self.fields['unsign']=unsign
       end

	end
end