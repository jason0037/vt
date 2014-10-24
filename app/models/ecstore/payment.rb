#encoding:utf-8
class Ecstore::Payment < Ecstore::Base
	self.table_name = 'sdb_ectools_payments'
	self.accessible_all_columns

	has_one :pay_bill,:foreign_key=>"bill_id",:class_name=>"Bill",:conditions=>{:pay_object=>"order",:bill_type=>"payments"}

	belongs_to :user,:foreign_key=>"member_id"

	belongs_to :operator, :foreign_key=>"op_id", :class_name=>"Account"

	has_one :payment_log

	PAYMENTS = {
    :ips => { :pay_name=>'环迅支付', :bank=> '环迅人民币支付', :pay_type=>"online" },
		#:bcom => { :pay_name=>'交通银行', :bank=> '交通银行网上支付', :pay_type=>"online" },
		#:icbc => { :pay_name=>'工商银行', :bank=> '工商银行网上支付', :pay_type=>"online" },
		:deposit => { :pay_name=>'预存款', :bank=> '预存款', :pay_type=>"deposit" },
		:offline => { :pay_name=>'线下支付', :bank=> '货到付款', :pay_type=>"offline" },
		#:'99bill' => { :pay_name=>'快钱支付', :bank=> '其他银行网上支付', :pay_type=>"online" },
		:alipay => { :pay_name=>'支付宝', :bank=> '支付宝', :pay_type=>"online" },
    :alipaywap => { :pay_name=>'支付宝手机版', :bank=> '支付宝手机版', :pay_type=>"online" },
    :wxpay => { :pay_name=>'微信支付', :bank=>'微信支付', :pay_type=>"online"}
	}

	#  status => enum('succ','failed','cancel','error','invalid','progress','timeout','ready')

	def self.generate_payment_id
          seq = rand(0..9999)
          loop do
              seq = 1 if seq == 9999
              _payment_id = Time.now.to_i.to_s + ( "%04d" % seq.to_s )
              return _payment_id unless  Ecstore::Payment.find_by_payment_id(_payment_id)
              seq += 1
          end
      end


      def paid?
      		self.status == 'succ'
      end

      def pay_type_text
      	   return '在线支付' if pay_type == 'online'
      	   return '线下支付' if pay_type == 'offline'
      end

      def paid_at
      		Time.at(t_payed||t_begin).strftime("%Y-%m-%d %H:%M:%S")
      end

      def status_text
	       return '支付成功' if status == 'succ'
		return '支付失败' if status == 'failed'
		return '支付取消' if status == 'cancel'
		return '支付错误' if status == 'error'
		return '非法支付' if status == 'invalid'
		return '支付处理中' if status == 'progress'
		return '支付超时' if status == 'timeout'
		return '准备中' if status == 'ready'
	end


      



       

end