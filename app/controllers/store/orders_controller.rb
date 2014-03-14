#encoding:utf-8
class Store::OrdersController < ApplicationController

	layout 'order'

  def to_inventory
       return_url =  request.env["HTTP_REFERER"]
       return_url =  member_goods_url if return_url.blank?

       @order_item =  Ecstore::OrderItem.find(params[:id])

       @new_inventory = Ecstore::Inventory.where(:member_id=>current_account,:product_id=>@order_item.product_id).first

       @inventory =  Ecstore::Inventory.new

      if @new_inventory.blank?
        @inventory.member_id = @order_item.order.member_id
        @inventory.goods_id =@order_item.goods_id
        @inventory.product_id =@order_item.product_id
        @inventory.price = @order_item.price
        @inventory.quantity =@order_item.nums
        @inventory.name =@order_item.name
        @inventory.bn = @order_item.bn
        @inventory.barcode = @order_item.product.barcode
        @inventory.save
      else
        quantity =  @new_inventory.quantity + @order_item.nums
        Ecstore::Inventory.where(:member_id=>current_account,:product_id=>@order_item.product_id).update_all(:quantity=>quantity)
      end


       Ecstore::InventoryLog.new do |inventory_log|
         inventory_log.in_or_out =true
         inventory_log.order_item_id=@order_item.item_id
         inventory_log.order_id = @order_item.order_id
         inventory_log.member_id = @order_item.order.member_id
         inventory_log.goods_id =@order_item.goods_id
         inventory_log.product_id =@order_item.product_id
         inventory_log.price = @order_item.price
         inventory_log.quantity =@order_item.nums
         inventory_log.name =@order_item.name
         inventory_log.bn = @order_item.bn
         inventory_log.barcode = @order_item.product.barcode
         inventory_log.createtime = Time.now.to_i
       end.save


      @order_item.update_attribute :storaged, true
      redirect_to return_url
  end

	def index
		@orders =  @user.orders.order("createtime desc")
	end

	def show
		@order = Ecstore::Order.find_by_order_id(params[:id])
	end

	def create
		addr = Ecstore::MemberAddr.find_by_addr_id(params[:member_addr])

		["name","area","addr","zip","tel","mobile"].each do |key,val|
			params[:order].merge!("ship_#{key}"=>addr.attributes[key])
		end
		params[:order].merge!(:ip=>request.remote_ip)
		params[:order].merge!(:member_id=>@user.member_id)

		@order = Ecstore::Order.new params[:order]

		@line_items.each do |line_item|
			product = line_item.product
			good = line_item.good

			@order.order_items << Ecstore::OrderItem.new do |order_item|
				order_item.product_id = product.product_id
				order_item.goods_id = good.goods_id
				order_item.type_id = good.type_id
				order_item.bn = product.bn
				order_item.name = product.name
        if cookies[:MLV] == "10"
				  order_item.price = product.bulk
        else
          order_item.price = product.price
        end
				order_item.nums = line_item.quantity.to_i
				order_item.item_type = "product"
				order_item.amount = order_item.price * order_item.nums

				product_attr = {}
				# product.spec_desc["spec_value"].each  do |spec_id,spec_value|
				# 	spec = Ecstore::Spec.find_by_spec_id(spec_id)
				# 	product_attr.merge!(spec_id=>{"label"=>spec.spec_name,"value"=>spec_value})
				# end
				order_item.addon = { :product_attr => product_attr }.serialize

				# @order.total_amount += order_item.calculate_amount
			end
		end

		# ==== promotion gifts =====
		gifts = params[:gifts] || []
		gifts.each do |gift_id|
			gift = Ecstore::Product.find_by_product_id(gift_id)
			@order.order_items  << Ecstore::OrderItem.new do |order_item|
				order_item.product_id = gift_id
				order_item.goods_id = gift.goods_id
				order_item.type_id = gift.good.type_id if gift.good
				order_item.bn = gift.bn
				order_item.name = gift.name
				order_item.price = gift.price
				order_item.nums = 1
				order_item.item_type = 'gift'
				order_item.addon = nil
				order_item.amount = 0
			end
		end


	     if @pmtable
		     # ==== coupons======
		     codes = params[:coupon].present? ? params[:coupon][:codes] : []
		     coupons =  codes.collect do |code|
				Ecstore::NewCoupon.check_and_find_by_code(code)
		     end.compact

	            coupons.each do |coupon|
	            		@order.order_pmts << Ecstore::OrderPmt.new do |order_pmt|
	            			order_pmt.pmt_type = 'coupon'
	            			order_pmt.pmt_id = coupon.id
	            			order_pmt.pmt_amount = coupon.pmt_amount(@line_items)
	            			order_pmt.pmt_name = coupon.name
	            			order_pmt.pmt_desc = coupon.desc
	            			order_pmt.coupon_code = coupon.current_code
	            		end
	            end
	            # === goods promotions =====
	            @goods_promotions = Ecstore::Promotion.matched_goods_promotions(@line_items)
	            @goods_promotions.each do |promotion|
	            		@order.order_pmts << Ecstore::OrderPmt.new do |order_pmt|
	            			order_pmt.pmt_type = 'goods'
	            			order_pmt.pmt_id = promotion.id
	            			order_pmt.pmt_amount = promotion.goods_pmt_amount(@line_items)
	            			order_pmt.pmt_name = promotion.name
	            			order_pmt.pmt_desc = promotion.desc
	            		end
	            end
	            # ==== order promotions =====
	            @order_promotions = Ecstore::Promotion.matched_promotions(@line_items)
	            @order_promotions.each do |promotion|
	            		@order.order_pmts << Ecstore::OrderPmt.new do |order_pmt|
	            			order_pmt.pmt_type = 'order'
	            			order_pmt.pmt_id = promotion.id
	            			order_pmt.pmt_amount = promotion.pmt_amount(@line_items)
	            			order_pmt.pmt_name = promotion.name
	            			order_pmt.pmt_desc = promotion.desc
	            		end
	            end
	       end

		if @order.save
			@line_items.delete_all

			Ecstore::OrderLog.new do |order_log|
				order_log.rel_id = @order.order_id
				order_log.op_id = @order.member_id
				order_log.op_name = @user.login_name
				order_log.alttime = @order.createtime
				order_log.behavior = 'creates'
				order_log.result = "SUCCESS"
				order_log.log_text = "订单创建成功！"
			end.save

			redirect_to order_path(@order)
			
		else
			@addrs =  @user.member_addrs
			@def_addr = @addrs.where(:def_addr=>1).first || @addrs.first
			@coupons = @user.usable_coupons
			render :new
		end

	end

	def new
		# @order = Ecstore::Order.new
		@addrs =  @user.member_addrs
		@def_addr = @addrs.where(:def_addr=>1).first || @addrs.first

		if @pmtable
			@order_promotions = Ecstore::Promotion.matched_promotions(@line_items)
			@goods_promotions = Ecstore::Promotion.matched_goods_promotions(@line_items)
			@coupons = @user.usable_coupons
		end
	end



	def pay
		@order  = Ecstore::Order.find_by_order_id(params[:id])
		if @order &&@order.status == 'active' && @order.pay_status == '0'
			@order.update_attribute :payment, params[:order][:payment]
		else
			render :text=>"不存在的订单不能支付!"
		end
	end

	def detail
		@order  = Ecstore::Order.find_by_order_id(params[:id])
	end

	def check_coupon
		codes = params[:codes] || []

		now_code = codes.delete_at(0)
		now_coupon = Ecstore::NewCoupon.check_and_find_by_code(now_code)

		unless now_coupon
			return render :js=>"alert('该优惠券不存在')"
		end

		@coupons = codes.collect do |code|
			Ecstore::NewCoupon.check_and_find_by_code(code)
		end.compact #.sort { |x,y| y.priority <=> x.priority }

		if @coupons.size > 0 && @coupons.include?(now_coupon)
			render :js=>"alert('同一种的优惠券只能使用一次')"
			return
		end

		@coupons << now_coupon if now_coupon

		@coupons.sort! { |x,y| y.priority <=> x.priority }

		@useable = {}
		exclusive = false

		@coupons.each do |coupon|
			if coupon.test_condition(@line_items)
				if !exclusive
					@useable[coupon.current_code] =  true
				else
					@useable[coupon.current_code] =  false
				end

				exclusive = coupon.exclusive
			else
				@useable[coupon.current_code] =  false
			end
		end

		@coupon_amount = @coupons.select do |coupon|
			@useable[coupon.current_code]
		end.collect { |coupon| coupon.pmt_amount(@line_items) }.inject(:+)

	end


end
