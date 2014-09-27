#encoding:utf-8
module ModecPay
  class Weixin < Payment

    @@appid = 'wxec23a03bf5422635'
    @@mch_id = '10011618'
    @@partner_key  = 'fe699e8e82144ddba567bcfcf441ece0'
    @@partnerid ='1221177901'

    @@sub_mch_id=''
    @@device_info=''

    def initialize
      super

      self.action = 'https://api.mch.weixin.qq.com/pay/unifiedorder'
      self.method = 'post'
      self.charset ='utf-8'

      self.appid = @@appid
      self.time_stamp = Time.now.to_i
      self.nonce_str = '' #随机串,不长于32位
      self.sign_type ='SHA1' #微信签名方式:1.sha1;2.md5 目前只支持SHA1

      self.sorter = Proc.new { |key,val| key }
      self.filter = Proc.new { |key,val| key.present? }

      #self.fields['appid'] = @@appid

      self.fields['bank_type'] = 'WX'
      self.fields['body'] = '订单商品' #商品描述 string(127)
      self.fields['partner'] = @@partnerid  #商户号 partnerId;
 #     self.fields['attach'] = ''
      self.fields['apbill_create_ip'] ='127.0.0.1' #订单生成的机器IP string(16)
      self.fields['fee_type'] ='1' #支持币种，1 ：人民币 ，目前只支持人民币
      self.fields['input_charset'] ='UTF-8' #传入参数字符编码，取值范围 “GBK”，“UTF-8”]
 #     self.fields['time_start'] = '' #订单生成时间 yyyyMMddHHmmss string(14)，否
 #     self.fields['time_expire'] = '' #交易结束时间时间 yyyyMMddHHmmss string（14），否
 #     self.fields['goods_tag'] = '' #商品标记，不能随便填 String（32），否
 #     self.fields['transport_fee'] = '' #物流费用，string，单位为分。如果有值，必须保证 transport_fee+product_fee=total_fee；否
 #     self.fields['product_fee'] = '' #物流费用，string，单位为分。如果有值，必须保证 transport_fee+product_fee=total_fee；否

 #     self.fields['trade_type'] = 'JSAPI' #JSAPI, NATIVE, APP
 #     self.fields['openid'] = '' #用户的openid, trade_type为JSAPP时，必传，否
 #     self.fields['products_id'] = '' #trade_type为NATIVE时，需要，此id为二维码中包含的商品ID

    end

   # def return_url=(val)
   #   self.fields['return_url'] = val
   # end

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
      self.fields['total_fee'] = (val*100).to_i #int fee*100 单位为分
    end

    def subject=(val)
      self.fields['attach'] = val #附加数据，原样返回 string(127),否
     # self.fields['subject'] = val
    end


    class <<  self
      def verify_sign(params)
        sign = params['sign']

        _sorted_hash = Hash.send :[],  params.select{ |key,val| val.present? && key != 'sign' && key != 'sign_type' }.sort_by{ |key,val|  key }

        unsign = _sorted_hash.collect do |key,val|
          "#{key}=#{val}"
        end.join("&") + @@partner_key

        Digest::MD5.hexdigest(unsign) == sign
      end

      def verify_notify(params,options)
        if verify_sign(params)

          ModecPay.logger.info "[weixin][#{Time.now}] payment=#{params['out_trade_no']} verify notify successfully."

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

      unsign = _sorted.collect{ |key,val| "#{key}=#{val}" }.join("&") + "key=#{@@partner_key}"
      self.fields['sign'] = Digest::MD5.hexdigest(unsign).upcase
    end

    def make_package
      return '' if self.fields.blank?

    #  bank_type   body   partner   out_trade_no   total_fee =  fee_type =  notify_url   spbill_create_id   input_charset

      _sorted = Hash.send :[],  self.fields.select{ |key,val|  val.present?&& key != 'sign_type' && key != 'sign' }.sort_by{ |key,val|  key }

      unsign = _sorted.collect{ |key,val| "#{key}=#{val}" }.join("&")+"sign=#{self.fields['sign']}"
      self.package = unsign
    end

    def make_pay_sign
      return '' if self.fields.blank?
      # appid  appkey  noncestr package timestamp traceid

      _sorted = Hash.send :[],  self.fields.select{ |key,val|  val.present?&& key != 'sign_type' && key != 'sign' }.sort_by{ |key,val|  key }

      unsign = _sorted.collect{ |key,val| "#{key}=#{val}" }.join("&") + self.key
      self.pay_sign = Digest::SHA1.hexdigest(unsign)
    end
=begin
生成xml
      @order_info.merge!('subOrderInfoList'=>{'subOrderInfo'=>@sub_order_info})
      @tran_data.merge!('orderInfo'=>@order_info)
      @tran_data.merge!('custom'=>@custom)
      @tran_data.merge!('message'=>@message)
      tran_data_xml = '<?xml version="1.0" encoding="GBK" standalone="no"?>' + @tran_data.to_xml(:root=>"B2CReq",:skip_instruct=>true,:indent=>0)
=end

  end
end