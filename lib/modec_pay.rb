require 'modec_pay/payment'
require 'modec_pay/alipay'
require 'modec_pay/alipaywap'
#require 'modec_pay/bill99'
#require 'modec_pay/bcom'
#require 'modec_pay/icbc'
require 'modec_pay/offline'
require 'modec_pay/deposit'
require 'modec_pay/ips'
require 'modec_pay/wxpay'

module ModecPay

	class << self

		def new(adapter)
			payment_class = adapters[adapter.to_s]
			payment_instance =  payment_class.new
			yield payment_instance if block_given?
			return payment_instance
		end

		def verify_notify(adapter, req_params,options={})
			ip = options.delete(:ip)
			payment_class = adapters[adapter.to_s]
			payment_class.verify_notify(req_params,options)
		end

		def verify_return(adapter, req_params,options={})
			ip = options.delete(:ip)
			payment_class = adapters[adapter.to_s]
			payment_class.verify_return(req_params,options)
		end

		def logger
			Logger.new("log/modec_pay.log")
		end


		def adapters
			{
          'ips' => ModecPay::Ips,
          'alipay' => ModecPay::Alipay,
          'alipaywap' => ModecPay::Alipaywap,
				# '99bill' => ModecPay::Bill99,
				# 'bcom' => ModecPay::Bcom,
				# 'icbc' => ModecPay::Icbc,
				 'offline'=> ModecPay::Offline,
				 'deposit'=> ModecPay::Deposit,
         'wxpay' => ModecPay::Wxpay
			}
		end
	end
end

