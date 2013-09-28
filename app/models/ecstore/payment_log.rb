class Ecstore::PaymentLog < Ecstore::Base
	self.table_name = "sdb_imodec_payment_logs"
	belongs_to  :payment
	

	self.accessible_all_columns

	[:request,:return,:notify].each do |method|
		class_eval <<-RUBY_EVAL,__FILE__,__LINE__+1
		  def #{method}_params_hash
		  	  params = self.send('#{method}_params')
		  	  return nil  if params.nil?
		  	  ActiveSupport::JSON.decode(params)
		  end
		RUBY_EVAL
	end

end