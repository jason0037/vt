#encoding:utf-8
module Admin::PromotionsHelper
	def promotion_conditions
		{ '订单金额大于等于' => ':total > %<target>d' }
	end

	def promotion_actions
		{ '减价' => 'minus',
		  '折扣' => 'discount',
		  '赠品' => 'gift',
		  '送优惠券'=>'coupon' }
	end
	def promotion_types
		{ :order=>'订单促销', :good=>'商品促销',:coupon=>'优惠券' }
	end

	def good_promotion_conditions
		{ '购买指定商品'=>'bn in (:target)', '加价购'=>':total + %<target>d', '搭配购买'=>'3' }
	end
	
end
