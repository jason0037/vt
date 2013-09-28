#encoding:utf-8
module Patch::CardsHelper
	
	def goto_pay_path
		bns = Ecstore::Config.where(:key=>['you_bn','chao_bn','ding_bn']).collect{ |c| c.value }
		cart_bns = @user.line_items.collect do |line_item|
			line_item.product.bn if line_item.product
		end

		if (bns&cart_bns).size > 0
			"#cart"
		else
			orders_member_path
		end
	end
end
