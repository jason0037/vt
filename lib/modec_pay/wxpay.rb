#encoding:utf-8

module ModecPay
  class Wxpay < Payment

    # @@appid = 'wxec23a03bf5422635'
    # @@mch_id = '10011618'
    # @@key  = 'fe699e8e82144ddba567bcfcf441ece0'
    # @@partnerid ='1221177901'

    # @@appid_manco = 'wx6b00b26294111729'
    # @@mch_id_manco = '10016674'
    # @@key_manco  = 'b97e61c87088d969b34534541ac98753'
    # @@partnerid_manco ='1220984601'

    @@sub_mch_id=''
    @@device_info=''

    def initialize
      super

      self.action = 'https://api.mch.weixin.qq.com/pay/unifiedorder'
      self.method = 'post'
      self.charset ='utf-8'

      self.sorter = Proc.new { |key,val| key }
      self.filter = Proc.new { |key,val| key.present? }

=begin
     # self.fields['sub_mch_id'] = @@sub_mch_id
     # self.fields['device_info']= @@device_info

     # self.fields['attach'] = 'trade-v' #附加数据原样返回

     # self.fields['time_start'] = '' #订单生成时间 yyyyMMddHHmmss string(14)，否
     # self.fields['time_expire'] = '' #交易结束时间时间 yyyyMMddHHmmss string（14），否
     # self.fields['goods_tag'] = '' #商品标记，不能随便填 String（32），否
     # self.fields['transport_fee'] = '' #物流费用，string，单位为分。如果有值，必须保证 transport_fee+product_fee=total_fee；否
     # self.fields['product_fee'] = '' #物流费用，string，单位为分。如果有值，必须保证 transport_fee+product_fee=total_fee；否

     # self.fields['bank_type'] = 'WX'
     # self.fields['partner'] = @@partnerid  #商户号 partnerId;

     # self.fields['fee_type'] ='1' #支持币种，1 ：人民币 ，目前只支持人民币
     # self.fields['input_charset'] ='UTF-8' #传入参数字符编码，取值范围 “GBK”，“UTF-8”]
=end
      self.fields['trade_type'] = 'JSAPI' #JSAPI, NATIVE, APP
      self.fields['openid'] = '' #用户的openid, trade_type为JSAPP时，必传，否
      self.fields['nonce_str'] =  Digest::MD5.hexdigest(rand(1000).to_s) #随机串,不长于32位
      self.fields['products_id'] = '' #trade_type为NATIVE时，需要，此id为二维码中包含的商品ID

    end

   # def return_url=(val)
   #   self.fields['return_url'] = val
   # end

    def appid=(val)
      self.fields['appid']=val
    end

    # def mch_id=(val)
    #   self.fields['mch_id'] = val
    # end

    def partner_key=(val)
      self.fields['attach'] = val
    end

    # def partnerid=(val)
    #   self.fields['mch_id'] = val
    # end

     def mch_id=(val)
      self.fields['mch_id'] = val
    end

    def supplier_id=(val)
      self.fields['device_info']=val
    end

    def spbill_create_ip=(val)
      self.fields['spbill_create_ip'] = val #订单生成的机器IP string(16)
    end

    def notify_url=(val)
      self.fields['notify_url'] = val #接受微信支付成功通知
    end


    def pay_id=(val)
      self.fields['out_trade_no'] = val #订单号 string(32)
    end

    def pay_time=(val)
      super
    end

    def pay_amount=(val)
      self.fields['total_fee'] = (val*100).to_i.to_s #int fee*100 单位为分
    end

    def openid=(val)
      self.fields['openid'] = val #支付用户openid
    end


    def subject=(val)
      self.fields['body'] = val  #商品信息
    end

    def attach=(val)
      self.fields['attach'] = val  #附加数据，原样返回 string(127),否
    end

    class <<  self
      def verify_sign(params)       

        sign = params['sign']

        #	_sorted_hash = Hash.send :[],  params.select{ |key,val| val.present? && key != 'sign' && key != 'sign_type' }.sort_by{ |key,val|  key }

        #unsign = _sorted_hash.collect do |key,val| 	"#{key}=#{val}" end.join("&") + @@private_key #self.private_key

        unsign_hash = Hash.send :[],  params.select{ |key,val| val.present? && key != 'sign' && key != 'sign_type' }
        unsign = unsign_hash.collect do |key,val| 	"#{key}=#{val}" end.join("&") + "&key=#{self.fields['attach']}"
        Digest::MD5.hexdigest(unsign) == sign
      end

      def verify_notify(params,options)
        if verify_sign(params)

          ModecPay.logger.info "[wxpay][#{Time.now}] payment=#{params['out_trade_no']} verify notify successfully."

          case params['return_code']
            when 'SUCCESS'
              t_payed = Time.now.to_i
              t_payed = Time.parse(params['time_end']).to_i  if params['time_end'].present?
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
          ModecPay.logger.info "[wxpay][#{Time.now}] verify return successfully."
          case params['return_code']
            when 'SUCCESS'
              t_payed = Time.now
              result = {  :payment_id=>params['out_trade_no'],
                          :trade_no=>params['transaction_id']
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
      _sorted = Hash.send :[],  self.fields.select{ |key,val|  val.present? }.sort_by{ |key,val|  key }
      unsign = _sorted.collect{ |key,val| "#{key}=#{val}" }.join("&") + "&key=#{self.fields['attach']}"
      self.fields['sign']  = Digest::MD5.hexdigest(unsign).upcase
    end

    def pre_pay
        make_sign
        self.fields['pre_pay_xml'] =  self.fields.to_xml(:root=>"xml",:skip_instruct=>true,:indent=>0,:dasherize => false)
        self.fields['time_stamp'] = Time.now.to_i
        self.fields['sign_type'] ='MD5' #微信签名方式:1.sha1;2.md5
    end

    def make_pay_sign

      return '' if self.fields.blank?
      unsorted={"appId" => self.fields["appid"],
                "nonceStr" => self.fields["nonce_str"],
                "package" => self.fields["package"],
                "timeStamp" => self.fields["time_stamp"],
                "signType" => self.fields['sign_type']
      }
      _sorted = Hash.send :[],  unsorted.select{ |key,val|  val.present? && key != 'sign_Type'}.sort_by{ |key,val|  key }
      unsign = _sorted.collect{ |key,val| "#{key}=#{val}" }.join("&") + "&key=#{self.fields['attach']}"
      self.fields['pay_sign'] = Digest::MD5.hexdigest(unsign).upcase
    end

  end
end