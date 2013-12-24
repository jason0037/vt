class Memberships::MemberCardsController < ApplicationController
	# skip_before_filter :authorize_user!
	# before_filter :find_user

	# def update
	# 	@member_card = Ecstore::MemberCard.find(params[:id])
	# 	@member_card.update_attribute :user_tel,params[:member_card][:user_tel]

	# 	redirect_to vip_url 
	# end

	# def create
	# 	@member_card = Ecstore::MemberCard.new(params[:member_card])
	# 	if @member_card.save(:validate=>false)
	# 		redirect_to card_path(:user,:mcid=>@member_card.id)
	# 	else
	# 		redirect_to card_path(:buyer)
	# 	end
	# end

	# def paid
	# 	order_id = params[:order_id]
	# 	@order = Ecstore::Order.where(:order_id=>order_id,
	# 									:member_id=>@user.member_id).first

	# 	if @order.pay_status == '0'
	# 		# unpay
	# 		render "memberships/cards/purchase/unpay"
	# 		return
	# 	end

	# 	# ids of card
	# 	product_bns = Ecstore::Config.where(:key=>['you_bn','chao_bn','ding_bn']).collect { |c| c.value }
	# 	product_ids = Ecstore::Product.where(:bn=>product_bns).collect { |p| p.product_id }
	# 	@order_items  = @order.order_items.where(:product_id => product_ids)
		
	# 	@bought_cards = [] 
	# 	@order_items.each do |item|
	# 		product = Ecstore::Product.find_by_product_id(item.product_id)
			
	# 		@cards = Ecstore::Card.joins(:member_card).where("sdb_imodec_member_cards.buyer_id = ? and pay_status = ? and  sale_status = ? and value = ?",@user.member_id,false,true,product.price)
			
	# 		if @cards.size ==  item.nums.to_i
	# 			@cards.update_all(:pay_status=>true)
	# 		elsif @cards.size > item.nums.to_i
	# 			@cards.limit(item.nums.to_i).update_all(:pay_status=>true)
	# 		else
	# 			@cards.update_all(:pay_status=>true)
	# 			(item.nums.to_i - @cards.size).times do
	# 				card = Ecstore::Card.where(:value=>product.price,
	# 									  :card_type=>"A",
	# 									  :sale_status=>false,
	# 									  :use_status=>false,
	# 									  :status=>"正常",
	# 									  :pay_status=>false).first
	# 				member_card =	 Ecstore::MemberCard.where(:buyer_id=>@user.member_id,
	# 														  :card_id=>nil).first_or_initialize do |mc|
	# 														   	mc.card_id = card.id
	# 														  end
	# 			end
	# 		end

	# 		item.nums.to_i.times do 
	# 			card = Ecstore::Card.where(:value=>product.price,
	# 								  :card_type=>"A",
	# 								  :sale_status=>false,
	# 								  :use_status=>false,
	# 								  :status=>"正常",
	# 								  :pay_status=>false).first
	# 			unless card
	# 				# no enough cards

	# 				return 
	# 			end
				
	# 			member_card =	 Ecstore::MemberCard.where(:buyer_id=>@user.member_id,
	# 														  :card_id=>nil).first_or_initialize do |mc|
	# 														   	mc.card_id = card.id
	# 														  end
 #                         pp member_card
	#                    if member_card.new_record?
	#                    		member_card.save(:validate=>false)
	#                    	else
	#                    		member_card.update_attribute :card_id, card.id
	#                    	end
	#                    card.sale_status = true
	#                    card.pay_status = true
	#                    card.sold_at = Time.now
	#                    card.save(:validate=>false)

	#                    @bought_cards << card
	#              end
	# 	end

	# 	render "memberships/cards/purchase/pay"

	# end
end