#encoding:utf-8
class Store::CartController < ApplicationController
	before_filter :find_user


  def index
    # render :layout=>"cart"
    supplier_id=params[:supplier_id]
    if supplier_id == nil
      supplier_id = 78
    end
    @supplier = Ecstore::Supplier.find(supplier_id)

    respond_to do  |format|
        format.html { render :layout=> 'cart'}
        format.mobile { render :layout=> 'msite'}
    end
  end

  def mobile
    supplier_id=params[:supplier_id]

    @goods_supplier = 0
    @bg_color = ["#cde6f3","#e5fdff"]
    @i = 0
    if  @user
         if supplier_id == nil
            supplier_id=78
         end
        @supplier = Ecstore::Supplier.find(supplier_id)
         render :layout=>@supplier.layout
    else
       redirect_to  "/auto_login?id=#{supplier_id}&platform=mobile&return_url=/cart/mobile?id=#{supplier_id}"
       #redirect_to "/mlogin?return_url=/cart/mobile"
    end

  end

	
	def add

		# parse params
    
    supplier_id=params[:supplier_id]

    if params[:supplier_id] =="98"
       @line_items.delete_all
    end

    if supplier_id.blank?
        supplier_id=78
    end

    @supplier = Ecstore::Supplier.find(supplier_id)


    if params[:attr]=="mall"
       @mall="mall"
      goods_id=params[:goods_id]

      quantity=1
      @good = Ecstore::Good.find(goods_id)
      @product = @good.products.first
    else
      specs = params[:product].delete(:specs)
      customs = params[:product].delete(:customs)
      quantity = params[:product].delete(:quantity).to_i
      goods_id = params[:product][:goods_id]
      ref_id=  params[:product][:ref_id]
      supplier_id= params[:supplier_id]
      #return render :text=> "specs:#{specs[0].length},customs:#{customs},quantity:#{quantity},goods_id:#{goods_id}"
      # product_id = specs.collect do |spec_value_id|
      # 	Ecstore::GoodSpec.where(params[:product].merge(:spec_value_id=>spec_value_id)).pluck(:product_id)
      # end.inject(:&).first
      if supplier_id =="98" && params[:mancoweight]
        quantity=params[:mancoweight].to_i
      end

      if quantity.blank? || quantity ==0
        quantity=1
      end
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
      cart.supplier_id=supplier_id
      cart.ref_id=ref_id
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

   
    if params[:zhuanghuo] ||params[:xiehuo]
      session[:zhuanghuo] =params[:zhuanghuo]
      session[:xiehuo] =params[:xiehuo]
    end

    if params[:platform]=="mobile"

      redirect_to "/cart/mobile?supplier_id=#{supplier_id}"

      #render "mobile", :layout=>@supplier.layout

    elsif params[:platform]=="manco_card" && supplier_id=="98"
      ###万家充值"
      redirect_to "/orders/manco_card?supplier_id=#{supplier_id}"

    elsif params[:platform]=="manco_local" && supplier_id=="98"
      redirect_to "/orders/arrival?supplier_id=#{supplier_id}&platform=#{params[:platform]}&member_departure_id=nil"
    elsif params[:platform] && supplier_id=="98"
      ###万家门对门
      url="/orders/departure?supplier_id=#{supplier_id}&platform=#{params[:platform]}"
      redirect_to url

    else
       render "add"
      #  respond_to do  |format|
      #     # format.mobile { render :layout=> 'msite'}
      #     format.mobile { render :layout=> 'msite'}
      # end
    end

	#rescue
		#render :text=>"add failed"
	end

  def distribution_manco
    @cats=Ecstore::GoodCat.where(:cat_id=>params[:cat_id]).first
    @supplier=Ecstore::Supplier.find_by_id(params[:supplier_id])
    render :layout => @supplier.layout
  end


	def update
		quantity = params[:quantity]
     unless params[:shop_id].nil?
       @shop_id= params[:shop_id]
       @line_items.where(:obj_ident=>params[:id],:shop_id=>@shop_id).update_all(:quantity=>quantity)
       @line_item  = @line_items.where(:obj_ident=>params[:id],:shop_id=>@shop_id).first
       session[:shop_id] = @shop_id
     else
		@line_items.where(:obj_ident=>params[:id]).update_all(:quantity=>quantity)
    @line_item  = @line_items.where(:obj_ident=>params[:id]).first
     end

		find_cart!
		render "update"
	end

	def destroy
		_type, goods_id, product_id = params[:id].split('_')
    if params[:shop_id]
      @shop_id= params[:shop_id]
      @line_items.where(:obj_ident=>params[:id],:shop_id=>@shop_id).delete_all

      session[:shop_id] = @shop_id
    else
		@line_items.where(:obj_ident=>params[:id]).delete_all
    end
		@user.custom_specs.where(:product_id=>product_id).delete_all if signed_in?

		find_cart!
  #  if params[:platform]=='mobile'
  #    return  render :text=>"删除成功"# redirect_to "/cart/mobile"
  #  else
  		render "destroy"
  #  end
	end

  def tairyo
    if @user


    account_id=params[:@order_dining][:account_id]
login_name=Ecstore::Account.find(account_id)
    hour=params[:hour]
    @oa = Ecstore::OrderDining.new(params[:@order_dining]) do |sv|
       sv.dining_use=login_name.login_name
      sv.dining_time=Time.parse(params[:@order_dining][:dining_time]).to_i+(hour.to_i)*3600
         end

       if @oa.save

       render   layout: "tairyo_new"
      else
      redirect_to  '/tairyo_order'
       end
  else
      redirect_to '/auto_login?id=99&platform=mobile&return_url=/tairyo_order'
    end


  end




   def manco_express
      @supplier=Ecstore::Supplier.find_by_id(params[:supplier_id])
     render :layout => @supplier.layout
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

  def tairyoall_add
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
      redirect_to "/cart/show_tairyo"
    else
      render "tairyoall_add"
    end
  end


  def show_tairyo
    render :layout => "tairyo_new"
  end
end
