#encoding:utf-8
class Ecstore::Refund < Ecstore::Base
	self.table_name  = 'sdb_ectools_refunds'
	self.accessible_all_columns

	has_one :bill, :foreign_key=>"bill_id", :conditions => {:bill_type=>"refunds"}

	belongs_to :operator, :foreign_key=>"op_id", :class_name=>"Account"

	def self.generate_refund_id
          seq = rand(0..9999)
          loop do
              seq = 1 if seq == 9999
              _refund_id = Time.now.to_i.to_s + ( "%04d" % seq.to_s )
              return _refund_id unless  Ecstore::Payment.find_by_payment_id(_refund_id)
              seq += 1
          end
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