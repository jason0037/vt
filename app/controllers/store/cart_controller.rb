#encoding:utf-8
class Store::CartController < ApplicationController
	# before_filter :find_user


  def index
		render :layout=>"cart"
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
    end

  end

	
	def add
		# parse params

    specs = params[:specs]
    goods_id = params[:goods_id]

		# specs = params[:product].delete(:specs)
		# customs = params[:product].delete(:customs)
		# quantity = params[:product].delete(:quantity).to_i
		# goods_id = params[:product][:goods_id]
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
      cart.supplier_id=@good.supplier_id
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
    #@supplier = Ecstore::Supplier.find(supplier_id)
		find_cart!

    supplier_id=params[:supplier_id]
    if supplier_id == nil
      supplier_id = 78

    end

    if params[:platform]=="mobile"

      redirect_to "/cart/mobile?supplier_id=#{supplier_id}"

      #render "mobile", :layout=>@supplier.layout


    else
       render "add"
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
