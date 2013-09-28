#encoding:utf-8
module ModecPay
	class Offline < Payment

		def initialize
			super
			self.method = 'get'
			self.charset ='utf-8'	

			self.filter = Proc.new { |key,val| key.present? }
		end
		
		def return_url=(val)
			self.action = val
		end

		def pay_id=(val)
			self.fields['payment_id'] = val
		end

		class << self
			def verify_notify(params,options)
				true
			end

			def verify_return(params,options)
				{   :payment_id=>params['payment_id'],
				    :trade_no=>nil,
				    :status=>'succ',
				    :t_payed=>Time.now.to_i,
				    :response => 'success'
				}
			end
		end

	     private 
	     def make_sign
	     end

	end
end