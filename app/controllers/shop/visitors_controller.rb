#encoding:utf-8
class Shop:: VisitorsController < ApplicationController

 layout "shop"

def istrue
   visitor=Ecstore::Visitor.where(:tel=>params[:visitor_tel])

  len = visitor.length
   if len==0
    return "0"
    else
    return "1"
    end
end

def my_add_shopping
  if params[:attr]=="mall"
    @mall="mall"
    goods_id=params[:goods_id]
    shop_id = params[:shop_id]
    quantity=1
    @good = Ecstore::Good.find(goods_id)
    @product = @good.products.first
  else
		specs = params[:product].delete(:specs)
		customs = params[:product].delete(:customs)
		quantity = params[:product].delete(:quantity).to_i
		goods_id = params[:product][:goods_id]
   shop_id = params[:product][:shop_id]

    if quantity.blank? || quantity ==0
       quantity=1
    end
   
		@good = Ecstore::Good.find(goods_id)
    if specs[0].empty?
      @product = @good.products.first
    else
      @product  =  @good.products.select do |p|
        p.good_specs.pluck(:spec_value_id).map{ |x| x.to_s }.sort == specs.sort
      end.first

    end
  end
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
			cart.member_id = @user.member_id
      cart.shop_id = shop_id
		end

		if @cart.new_record?
			@cart.save
		else
			Ecstore::Cart.where(:obj_ident=>@cart.obj_ident,:member_ident=>member_ident).update_all(:quantity=>@cart.quantity+quantity)
			@cart.quantity = (@cart.quantity+1)
		end

		session[:shop_id] = shop_id

    find_cart!
   
    if params[:platform]=="shop"
      redirect_to "/shop/visitors/my_shopping_cart?shop_id=#{shop_id}"
    else
       render "my_add_shopping"
    end

end


def my_shopping_cart
  @shop_title="我的购物车"
  @shop_id=params[:shop_id]
  session[:shop_id] = @shop_id
  @line_items = Ecstore::Cart.where(:member_id=>current_account.account_id,:shop_id=>@shop_id)
  @cart_total_quantity = @line_items.inject(0){ |t,l| t+=l.quantity }.to_i || 0
  
      
  @cart_total1=0  ###团购
  @cart_total2=0
  @cart_total=0

  if cookies[:MLV] == "10"
    @line_items.each do |li|
      unless li.ref_id.nil?
        if li.quantity.to_i>li.ecstore_goods_promotion_ref.persons.to_i-1
          @cart_total1 += li.ecstore_goods_promotion_ref.promotionsprice*li.quantity
        else
           @cart_total2 += li.product.price*li.quantity
        end
      else
        @cart_total2 += li.product.bulk*li.quantity
        #    @line_items.select{|x| x.product.present? }.collect{ |x| (x.product.bulk*x.quantity) }.inject(:+) || 0
      end
    end
  else
    @line_items.each do |li|
      unless li.ref_id.nil?
        if li.quantity.to_i>li.ecstore_goods_promotion_ref.persons.to_i-1
          @cart_total1= @cart_total1+li.ecstore_goods_promotion_ref.promotionsprice*li.quantity
        else
           @cart_total2 =  @cart_total2+ li.product.price*li.quantity
        end
      else
          @cart_total2 =  @cart_total2+ li.product.price*li.quantity
          # @line_items.select{|x| x.product.present? }.collect{ |x| (x.product.price*x.quantity) }.inject(:+) || 0
      end   
    end
  end
  @cart_total = @cart_total1 + @cart_total2
end

def order_clearing

    @shop_id=params[:shop_id]

    supplier_id= @shop_id

     sql = "SELECT SUM(price*quantity) AS total,mdk.sdb_b2c_cart_objects.supplier_id,SUM(freight)/count(*) AS freight FROM mdk.sdb_b2c_cart_objects
  INNER JOIN mdk.sdb_b2c_goods ON SUBSTRING_INDEX(SUBSTRING_INDEX(mdk.sdb_b2c_cart_objects.obj_ident,'_',2),'_',-1) = mdk.sdb_b2c_goods.goods_id
  WHERE mdk.sdb_b2c_cart_objects.member_id=#{@user.member_id} GROUP BY mdk.sdb_b2c_cart_objects.supplier_id"
      @cart_total_by_supplier = ActiveRecord::Base.connection.execute(sql)
      @cart_freight = 0
      @favorable_terms = 0

      @cart_total_by_supplier.each(:as => :hash) do |row|
        if (row["total"]>=60 && row["supplier_id"]==97) || (row["total"]>=380 &&row["supplier_id"]==77) #|| @cart_total==0.01 #测试商品
          @favorable_terms -=row["freight"]
        end
        @cart_freight += row["freight"]
      end

      @cart_total_final = @cart_total+ @cart_freight + @favorable_terms

        @def_addr =  @user.member_addrs.first
    if @def_addr.nil?
      redirect_to "/member_addrs/new_memberaddr_add?return_url=/shop/visitors/order_clearing"

      # redirect_to "/shop/goodsaddrs/new_addr?return_url=/shop/visitors/order_clearing?supplier_id=#{@shop_id}"
    end

    if @pmtable
          @order_promotions = Ecstore::Promotion.matched_promotions(@line_items)
          @goods_promotions = Ecstore::Promotion.matched_goods_promotions(@line_items)
          @coupons = @user.usable_coupons
    end
  end

  def  order_show
    @shop_title="我的订单"
    @shop_id = params[:shop_id]
    @order = Ecstore::Order.find_by_order_id(params[:id])
    render :layout=>'shop'
  end

end
