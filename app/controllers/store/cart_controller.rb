#encoding:utf-8
class Store::CartController < ApplicationController
	# before_filter :find_user


  def index
		render :layout=>"cart"
  end

  def mobile
    if params[:id]
      @supplier  =  Ecstore::Supplier.find(params[:id])
      render :layout=>@supplier.url
    else
      render :layout=>"mobile_new"
    end
  end

	
	def add
		
		# parse params
		specs = params[:product].delete(:specs)
		customs = params[:product].delete(:customs)
		quantity = params[:product].delete(:quantity).to_i
		goods_id = params[:product][:goods_id]

    if quantity.blank? || quantity ==0
      quantity=1
    end

#return render :text=> "specs:#{specs[0].length},customs:#{customs},quantity:#{quantity},goods_id:#{goods_id}"
		# product_id = specs.collect do |spec_value_id|
		# 	Ecstore::GoodSpec.where(params[:product].merge(:spec_value_id=>spec_value_id)).pluck(:product_id)
		# end.inject(:&).first

		@good = Ecstore::Good.find(goods_id)
		# @product  =  @good.products.select do |p|
		# 	p.spec_desc["spec_value_id"].values.map{ |x| x.to_s }.sort == specs.sort
		# end.first
    if specs[0].empty?
      @product = @good.products.first
    else
      @product  =  @good.products.select do |p|
        p.good_specs.pluck(:spec_value_id).map{ |x| x.to_s }.sort == specs.sort
      end.first

    end
#return render :text=>@products.product_id
		if signed_in?
			member_id = @user.member_id
			member_ident = Digest::MD5.hexdigest(@user.member_id.to_s)
		else
			member_id = -1
			member_ident = @m_id
		end

		@cart = Ecstore::Cart.where(:obj_ident=>"goods_#{goods_id}_#{@product.product_id}",
									  :member_ident=>member_ident).first_or_initialize do |cart|
			cart.obj_type = "goods"
			cart.quantity = quantity
			cart.time = Time.now.to_i
			cart.member_id = member_id
		end

		if @cart.new_record?
			@cart.save
		else
			Ecstore::Cart.where(:obj_ident=>@cart.obj_ident,:member_ident=>member_ident).update_all(:quantity=>@cart.quantity+quantity)
			@cart.quantity = (@cart.quantity+1)
		end
		
		# if @product.semi_custom?
		# 	ident = "#{@user.member_id}#{@product.product_id}#{Time.now.to_i}"
		# 	customs.each do |cus_val|
		# 		cus_val.merge!(:product_id=>@product.product_id,
		# 						:member_id=>@user.member_id,
		# 						:name=>Ecstore::SpecItem.find(cus_val["spec_item_id"]).name,
		# 						:ident=>ident)

		# 		Ecstore::CustomValue.create(cus_val)
		# 	end if customs
		# end

		#calculate cart_total and cart_total_quantity
		find_cart!
    if params[:platform]=='mobile'
      redirect_to "/cart/mobile"
    else
      render "add"
    end

	#rescue 
		#render :text=>"add failed"
	end
	
	def update
		quantity = params[:quantity]
		@line_items.where(:obj_ident=>params[:id]).update_all(:quantity=>quantity)
		@line_item  = @line_items.where(:obj_ident=>params[:id]).first
		find_cart!
		render "update"
	end

	def destroy
		_type, goods_id, product_id = params[:id].split('_')
		@line_items.where(:obj_ident=>params[:id]).delete_all
		@user.custom_specs.where(:product_id=>product_id).delete_all if signed_in?

		find_cart!
  #  if params[:platform]=='mobile'
  #    return  render :text=>"删除成功"# redirect_to "/cart/mobile"
  #  else
  		render "destroy"
  #  end
	end

  def tairyo


    @oa = Ecstore::OrderDining.new(params[:@order_dining])
   #
     if @oa.save

      render   layout: "tairyo_new"
     else
     redirect_to  '/tairyo_order'
    end


   end
  def tairyo_cart
   render   layout: "tairyo_new"
  end


  def mancoexpress_add

    specs = params[:product].delete(:specs)
    customs = params[:product].delete(:customs)
    quantity = params[:product].delete(:quantity).to_i
   if quantity.blank? || quantity ==0
      quantity=1
    end
    goods_id= params[:goods_id]     ##商品名称
    @manco_unit_price =params[:manco_unit_price]
   mancoweight=params[:mancoweight]

    @manco_total=  @manco_unit_price.to_f * mancoweight.to_f

    @good=Ecstore::Good.find(goods_id)
    @product = @good.products.first
#
    if signed_in?
      member_id = @user.member_id
      member_ident = Digest::MD5.hexdigest(@user.member_id.to_s)
    else
      member_id = -1
      member_ident = @m_id
    end

    @cart = Ecstore::Cart.where(:obj_ident=>"goods_#{goods_id}_#{@product.product_id}",
                                :member_ident=>member_ident).first_or_initialize do |cart|
      cart.obj_type = "goods"
      cart.quantity = (mancoweight.to_f+0.5)
      cart.time = Time.now.to_i
      cart.member_id = member_id
    end

    if @cart.new_record?
      @cart.save
    else
      Ecstore::Cart.where(:obj_ident=>@cart.obj_ident,:member_ident=>member_ident).update_all(:quantity=>@cart.quantity+quantity)
      @cart.quantity = (@cart.quantity+1)
    end


    find_cart!
    if params[:platform]=='mancoexpress'
      redirect_to "/cart/manco_express"
    else
      respond_to  do |format|
     format.js
        end
    end
    end


   def manco_express
      render :layout => "manco_new"
   end


   def manco_add        ###小黑板的购物
     specs = params[:product].delete(:specs)
     customs = params[:product].delete(:customs)
     quantity = params[:product].delete(:quantity).to_i
     if quantity.blank? || quantity ==0
       quantity=1
     end
     goods_id = params[:product][:goods_id]
     @manco_unit_price =params[:manco_unit_price]
     mancoweight=params[:mancoweight]

     @manco_total=  @manco_unit_price.to_f * mancoweight.to_f

     @good=Ecstore::Good.find(goods_id)
     @product = @good.products.first
#
     if signed_in?
       member_id = @user.member_id
       member_ident = Digest::MD5.hexdigest(@user.member_id.to_s)
     else
       member_id = -1
       member_ident = @m_id
     end

     @cart = Ecstore::Cart.where(:obj_ident=>"goods_#{goods_id}_#{@product.product_id}",
                                 :member_ident=>member_ident).first_or_initialize do |cart|
       cart.obj_type = "goods"
       cart.quantity = (mancoweight.to_f+0.5)
       cart.time = Time.now.to_i
       cart.member_id = member_id
     end

     if @cart.new_record?
       @cart.save
     else
       Ecstore::Cart.where(:obj_ident=>@cart.obj_ident,:member_ident=>member_ident).update_all(:quantity=>@cart.quantity+quantity)
       @cart.quantity = (@cart.quantity+1)
     end



     find_cart!
     if params[:platform]=='manco'
       redirect_to "/cart/manco_black_buy"
     else
       render "manco_add"
     end
   end

   def manco_black_buy

   render :layout => "manco_new"
  end

  def tairyo_add


    specs = params[:product].delete(:specs)
    customs = params[:product].delete(:customs)

    goods_id = params[:product][:goods_id]




    @good = Ecstore::Good.find(goods_id)
#

    @product = @good.products.first
#
    if signed_in?
      member_id = @user.member_id
      member_ident = Digest::MD5.hexdigest(@user.member_id.to_s)
    else
      member_id = -1
      member_ident = @m_id
    end

    @cart = Ecstore::Cart.where(:obj_ident=>"goods_#{goods_id}_#{@product.product_id}",
                                :member_ident=>member_ident).first_or_initialize do |cart|
      cart.obj_type = "goods"
      cart.quantity = 1
      cart.time = Time.now.to_i
      cart.member_id = member_id
    end

    if @cart.new_record?
      @cart.save

    end


    find_cart!
    if params[:platform]=='tairyo'
      redirect_to "/cart/jinbalang"
    else
      render "tairyo_add"
    end
  end


 def jinbalang

    render :layout => "tairyo_new"
  end



   end
