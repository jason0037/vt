
module ModecPay

	class Payment

		attr_accessor :mer_id, :private_key
		attr_accessor :action, :method, :charset
		attr_accessor :fields
		attr_accessor :filter
		
		attr_accessor :return_url, :notify_url
		
		attr_accessor :installment

		#  payment id in db
		attr_accessor :pay_id

		attr_accessor :pay_time, :pay_amount

		# payment subject
		attr_accessor :subject

		# payment description
		attr_accessor :body

		# A block pass to sort_by 
		# == Example
		#   payment.sorter = Proc.new { |key,val|  key }
		# Or a Array that contain fields,specify the order
		# == Example
		#   payment.sorter = ['version','lan','sign','_charset']
		#   if extra  in fields,those extra will append to fields
		#   
		#   This is used to order fields for form
		attr_accessor :sorter 

		def initialize
			self.fields = {}
		end

		def html_form
			make_sign

			if sorter.is_a?(Proc)
			    self.fields = Hash.send :[],  self.fields.select{ |key,val|  val.present? }.sort_by(&self.sorter)
			end

			if sorter.is_a?(Array)
				_fields = self.fields.dup
				self.fields = {}
				sorter.each do |key|
					self.fields[key] = _fields.delete(key)
				end
				self.fields.merge!(_fields)  unless _fields.empty?
			end

			_filter = self.filter if self.filter.is_a?(Proc)
			_filter = proc { true }  unless _filter

			form_inputs = self.fields.select(&_filter).collect do |key,val|
				"<input type='hidden' name='#{key}' value='#{val}' />"
			end.join(" ")

			<<-FORM
				<!DOCTYPE html>
				<html>
				<head>
					<meta http-equiv="Content-Type" content="text/html; charset=#{self.charset}">
					<title>Redirecting...</title>
				</head>
				<body>
				<div>Redirecting...</div>
				<form accept-charset="#{self.charset}" action="#{self.action}" method="#{self.method}" id="pay_form">
					#{form_inputs}
				</form>
				<script type="text/javascript">
					window.onload=function(){
						document.getElementById("pay_form").submit();
					}
				</script>
				</body>
				</html>
			FORM
		end

		private 

		#  === Example 
		#  def make_sign
		#      _sign = "secret string"
		#      self.fields['sign'] = _sign
		#  end
		def make_sign
			warn 'TODO: Add signature to fields'
		end

	end

end