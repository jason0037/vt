#encoding:utf-8
module Store::GoodsHelper
	def body_style
		content_for :body_style || ("height:#{ @goods.size * 1000 + 150  }px;" if @goods)
	end
end
