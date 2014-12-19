#encoding:utf-8
class Shop:: VisitorsController < ApplicationController
  before_filter :find_shop_user
 layout "shop"

def login
    if @user
      sign_out
    end

   @shop_id=params[:shop_id]
    name=Ecstore::Shop.find_by_shop_id(@shop_id).shop_name
   @shop_title="登陆#{name}的微店"

end

def register
  if @user
    sign_out
  end
   @shop_id=params[:shop_id]
  name=Ecstore::Shop.find_by_shop_id(@shop_id).shop_name
  @shop_title="注册#{name}的微店"
end

def login_in
  shop_id=params[:visitor][:shop_id]
  return_url=params[:return_url]
 @visitors = Ecstore::Visitor.find_by_visitor_name(params[:visitor][:visitor_name])
   if @visitors &&@visitors.visitor_password==params[:visitor][:visitor_password]
     sing_shop_in(@visitors)
    redirect_to return_url+"&shop_id="+shop_id
  else
    redirect_to "/visitors/login?shop_id=#{shop_id}&return_url=#{return_url}", :notice=>"您输入有误,登陆失败"
    end
end

def register_user

  @shop_id=params[:visitor][:shop_id]
  @visi= Ecstore::Visitor.find_by_visitor_name(params[:visitor][:visitor_name])
  if @visi
    redirect_to "/visitors/register?shop_id=#{@shop_id}", :notice=>"用户名已经存在"

  else
    @visitors=Ecstore::Visitor.new(params[:visitor])
   if  @visitors.save
    sing_shop_in(@visitors)
     redirect_to "/shopinfos/myshop?shop_id="+@shop_id
    end

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

   
    if params[:platform]=="shop"

      redirect_to "/visitors/my_shopping_cart?supplier_id=#{@shop_id}&user_id="+@user_id

    else
       render "my_add_shopping"
    end


end


def my_shopping_cart
    @shop_title="我的购物车"
    @supplier_id=params[:supplier_id]
   # return render :text=>@supplier_id
    @user_id=params[:user_id]



end

def order_clearing

  @shop_id=params[:supplier_id]


    supplier_id= @visitors.shop_id



   sql = "SELECT SUM(price*quantity) AS total,mdk.sdb_b2c_cart_objects.supplier_id,SUM(freight)/count(*) AS freight FROM mdk.sdb_b2c_cart_objects
INNER JOIN mdk.sdb_b2c_goods ON SUBSTRING_INDEX(SUBSTRING_INDEX(mdk.sdb_b2c_cart_objects.obj_ident,'_',2),'_',-1) = mdk.sdb_b2c_goods.goods_id
WHERE mdk.sdb_b2c_cart_objects.member_id=#{@visitors.id}
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

      @def_addr =  Ecstore::Visitor.find(params[:user_id])
  if @def_addr.address.nil?


    redirect_to "/goodsaddrs/new_addr?return_url=/visitors/order_clearing?supplier_id=#{@shop_id}&user_id=#{params[:user_id]}"
  end


  if @pmtable
        @order_promotions = Ecstore::Promotion.matched_promotions(@line_items)
        @goods_promotions = Ecstore::Promotion.matched_goods_promotions(@line_items)
        @coupons = @user.usable_coupons
      end



end



def  order_show
     @shop_title="我的订单"
  @supplier_id = params[:supplier_id]
  @order = Ecstore::Order.find_by_order_id(params[:id])




render :layout=>'shop'
end

end
