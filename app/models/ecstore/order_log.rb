#encoding:utf-8
class Ecstore::OrderLog < Ecstore::Base
	self.table_name = "sdb_b2c_order_log"
	belongs_to :order, :foreign_key=>"rel_id"


	def created_at
		Time.at(self.alttime).strftime("%Y-%m-%d %H:%M:%S") if self.alttime
	end

	def log_text
		begin
			if super.deserialize.is_a?(Hash)
				super.deserialize["txt_key"] || super.deserialize[0]["txt_key"]
			else
				super
			end
		rescue Exception => e
			return "发货完成." if self.behavior == "delivery"
			return "退货完成." if self.behavior == "reship"
			return "买家已经付款." if self.behavior == "payments"
			return "订单取消." if self.behavior == "cancel"
		end
	end	

	# 'creates','updates','payments','refunds','delivery','reship','finish','cancel'
	def behavior_name
		return '创建' if self.behavior == 'creates'
		return '更新' if self.behavior == 'updates'
		return '支付' if self.behavior == 'payments'
		return '退款' if self.behavior == 'refunds'
		return '发货' if self.behavior == 'delivery'
		return '退货' if self.behavior == 'reship'
		return '完成' if self.behavior == 'finish'
		return '作废' if self.behavior == 'cancel'
		return '备注' if self.behavior == 'memo'
	end

	# 'SUCCESS','FAILURE'
	def result_name
		return '成功' if self.result == "SUCCESS"
		return '失败' if self.result == "FAILURE"
	end


end