#encoding:utf-8
module Admin::CardsHelper

	def unsold_card_status_options
		{ '正常'=>'正常','作废'=>'作废' }
	end

	def sold_card_status_options
		{ '正常'=>'正常','锁定'=>'锁定' }
	end

	def search_options
		{"用户名"=>'login_name',"手机号码"=>"mobile"}
	end

	def card_sale_status_options
		{"未销售"=>0,"已销售"=>1}
	end

	def card_use_status_options
		{"未使用"=>0,"已使用"=>1}
	end

	def sold_card_pay_status_options
		{"未付款"=>false,"付款"=>true}
	end

	def level(val)
		case val
			when 10000; "优摩"
			when 20000; "超摩"
			when 50000; "顶摩"

		end
	end

end
