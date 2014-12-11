#encoding:utf-8
class Shop:: VisitorsController < ApplicationController

 layout "shop"

def login
   @shop_id=params[:shop_id]
end

def register
   @shop_id=params[:shop_id]
end

def login_in

     #params[:visitor]
     @v = Ecstore::Visitor.where(:tel=>params[:visitor][:visitor_tel],:visitor_password=>params[:visitor][:visitor_password])
      shop_id=params[:visitor][:shop_id]
   if @v.nil?
     
    else
       redirect_to "/shopinfos/my_goods?shop_id="+shop_id
   end
end

def register_user

  visitor=Ecstore::Visitor.where(:tel=>params[:visitor][:visitor_tel])
len =visitor.length
   if len==0

  @visitor=Ecstore::Visitor.new do |v|
   v.tel=params[:visitor][:visitor_tel]
   v.visitor_password=params[:visitor][:visitor_password]
   end.save

    @shop_id=params[:visitor][:shop_id]
  
   redirect_to "/visitors/login?shop_id="+@shop_id
 else
  
  end

  
end

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

		specs = params[:product].delete(:specs)
		customs = params[:product].delete(:customs)
		quantity = params[:product].delete(:quantity).to_i
		goods_id = params[:product][:goods_id]
		@user_id = params[:product][:user_id]
      		@shop_id = params[:product][:shop_id]
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
			cart.member_id = @user_id
      			cart.supplier_id=@shop_id
		end

		if @cart.new_record?
			@cart.save
		else
			Ecstore::Cart.where(:obj_ident=>@cart.obj_ident,:member_ident=>member_ident).update_all(:quantity=>@cart.quantity+quantity)
			@cart.quantity = (@cart.quantity+1)
		end

		
		find_cart!

    supplier_id=@shop_id
    if supplier_id == nil
      supplier_id = 78

    end
   
    if params[:platform]=="mobile"

      redirect_to "/visitors/my_shopping_cart?supplier_id=#{@shop_id}&user_id="+@user_id

    else
       render "my_add_shopping"
    end


end


def my_shopping_cart

    @supplier_id=params[:supplier_id]
   # return render :text=>@supplier_id
    @user_id=params[:user_id]

    @goods_supplier = 0
    @bg_color = ["#cde6f3","#e5fdff"]
    @i = 0
    if  @user
       #  if @supplier_id == nil
           # @supplier_id=78
        # end
        @supplier = Ecstore::Supplier.find(78)
         render :layout=>@supplier.layout
    else
       #redirect_to  "/auto_login?id=#{supplier_id}&platform=mobile&return_url=/cart/mobile?id=#{supplier_id}"
    end

end

def order_clearing


    session[:arrivals]=nil
    session[:zhuanghuo] =nil
    session[:xiehuo] =nil
    supplier_id= @user.account.supplier_id

    if supplier_id.nil?
      supplier_id=78
    end

   sql = "SELECT SUM(price*quantity) AS total,mdk.sdb_b2c_cart_objects.supplier_id,SUM(freight)/count(*) AS freight FROM mdk.sdb_b2c_cart_objects
INNER JOIN mdk.sdb_b2c_goods ON SUBSTRING_INDEX(SUBSTRING_INDEX(mdk.sdb_b2c_cart_objects.obj_ident,'_',2),'_',-1) = mdk.sdb_b2c_goods.goods_id
WHERE mdk.sdb_b2c_cart_objects.member_id=#{@user.member_id}
GROUP BY mdk.sdb_b2c_cart_objects.supplier_id"
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
    @addrs =  @user.member_addrs
    if @addrs.size==0
      redirect_to "/orders/new_mobile_addr?supplier_id=#{supplier_id}&return_url=%2forders%2fnew_mobile?supplier_id%3d#{supplier_id}"
    else
      @def_addr = @addrs.where(:def_addr=>1).first || @addrs.first

      if @pmtable
        @order_promotions = Ecstore::Promotion.matched_promotions(@line_items)
        @goods_promotions = Ecstore::Promotion.matched_goods_promotions(@line_items)
        @coupons = @user.usable_coupons
      end
      @supplier = Ecstore::Supplier.find(supplier_id)
      render :layout=>@supplier.layout
    end


end



end
