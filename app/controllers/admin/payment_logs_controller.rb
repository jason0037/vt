require 'base64'
require 'modec_pay'
class Admin::PaymentLogsController < Admin::BaseController
	def index
		@payment_logs = Ecstore::PaymentLog
		if params[:s] && params[:s][:q]
			@payment_logs = @payment_logs.where("order_id like :key or payment_id like :key", { :key=>"%#{params[:s][:q]}%"})
		end
		@payment_logs = @payment_logs.paginate(:page=>params[:page],:per_page=>10)
	end
end
