#encoding:utf-8
require 'pp'

module ModecPay
	class Ips < Payment
		
		def initialize
			super
=begin
			#测试环境begin
      self.mer_id = '000015'
      self.private_key ='GDgLwwdK270Qj1w4xho8lyTpRQZV9Jm5x4NwWOTThUa4fMhEBK9jOXFrKRT6xhlJuU2FEa89ov0ryyjfJuuPkcGzO5CeVx5ZIrkkt1aBlZV36ySvHOMcNv8rncRiy3DQ'
      self.action = 'https://pay.ips.net.cn/ipayment.aspx'
      #测试环境end
=end
      #生产环境begin
      self.mer_id = '026824'
      self.private_key ='67500813039244903894807512175740448373826983882523618896908763738870562996891363055213255137515215490195061109453460851561433548'
			self.action = 'https://pay.ips.com.cn/ipayment.aspx'
      #生产环境begin

			self.method = 'post'
			self.charset ='gbk'

			self.sorter = ['Mer_code','Billno','Amount','Date','Currency_Type',
                     'Gateway_Type','Lang','Merchanturl','FailUrl','ErrorUrl' ,
                     'Attach','OrderEncodeType','RetEncodeType','Rettype',
                     'ServerUrl','SignMD5']

			self.fields['Mer_code'] = mer_id
      self.fields['Currency_Type'] = 'RMB'
			self.fields['Gateway_Type'] ='01'
      # 01:借记卡; 04:IPS账户支付; 08:IB支付; 16:电话支付; 64:储值卡支付
			self.fields['Lang'] = 'GB'
			self.fields['FailUrl'] = ''
			self.fields['ErrorUrl'] = ''
			self.fields['Attach'] =''
			self.fields['OrderEncodeType'] = '5' # 5:md5摘要
			self.fields['RetEncodeType'] ='17' # 16:md5withRsa; 17:md5摘要
			self.fields['Rettype'] ='1'  #0:无Server to Server; 1:有Server to Server

		end

		def return_url=(val)
      self.fields['ServerUrl'] = val
		end

		def notify_url=(val)
      self.fields['Merchanturl'] =val
		end

		def pay_id=(val)
      self.fields['Billno'] =  val
		end

		def pay_time=(val)
			val = Time.now unless val.is_a?(Time)
			self.fields['Date'] = val.strftime("%Y%m%d")
		end

		def pay_amount=(val)
			self.fields['Amount'] =  format("%0.2f",  val)
		end

    class << self
      def verify_sign(params)
        sign = params['signature']

        unsign_hash = {
            "billno"=>params["billno"],
            "currencytype"=>params["Currency_type"],
            "amount"=>params["amount"],
            "date"=>params["date"],
            "succ"=>params["succ"],
            "ipsbillno"=>params["ipsbillno"],
            "retencodetype"=>params["retencodetype"]
        }
        private_key ='67500813039244903894807512175740448373826983882523618896908763738870562996891363055213255137515215490195061109453460851561433548'

        unsign = unsign_hash.select{ |key,val| val.present? }.collect do |key,val|
          "#{key}#{val}"
        end.join() +private_key
        Digest::MD5.hexdigest(unsign).downcase == sign.downcase
      end

      def verify_notify(params,options)
        ips_redirect_url = options.delete(:ips_redirect_url)
        if verify_sign(params)
          case params['succ']
            when 'Y'
              t_payed = Time.now.to_i
              t_payed = Time.parse(params['data'].to_s).to_i  if params['dealTime'].present?
              result = {  :payment_id=>params['billno'],
                          :trade_no=>params['ipsbillno'],
                          :status=>'succ',
                          :t_payed=>t_payed,
                          :response => params['msg']
              }
            else
              result = "<redirecturl>#{ params['msg']}?status=failed</redirecturl>"
          end
        else
          result = "<redirecturl>#{params['msg']}?status=invalid</redirecturl>"
        end

        result
      end

      def verify_return(params,options)
        verify_notify(params,options)
      end

    end

    private

    def make_sign

      # /订单支付接口的Md5摘要，原文=订单号+金额+日期+支付币种+商户证书
      # cryptix.jce.provider.MD5 b=new cryptix.jce.provider.MD5();
      # {/}"/订单加密的明文 billno+【订单编号】+ currencytype +【币种】+ amount +【订单金额】+ date +【订单日期】+ orderencodetype +【订单支付接口加密方式】+【商户内部证书字符串】
      # {String}" SignMD5 = b.toMD5("billno"+Billno +"currencytype"+Currency_Type+"amount"+ Amount + "date" +Date +"orderencodetype"+OrderEncodeType + Mer_key).toLowerCase();

       unsign_hash = {
          "billno"=>self.fields['Billno'],
          "currencytype"=>self.fields['Currency_Type'],
          "amount"=>self.fields['Amount'],
          "date"=>self.fields['Date'],
          "orderencodetype"=>self.fields['OrderEncodeType']
      }

      unsign = unsign_hash.select{ |key,val| val.present? }.collect do |key,val|
        "#{key}#{val}"
      end.join() + private_key
      self.fields['unsign']=unsign
      self.fields.merge!('SignMD5'=>Digest::MD5.hexdigest(unsign).downcase)
    end

  end

end