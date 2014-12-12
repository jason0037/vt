
#encoding:utf-8
class Shop:: ShopinfosController < ApplicationController
 layout "shop"

 def register
    @shop_id=params[:shop_id]
   @shop_title="创建店铺"

 end


  def shop_add
	
        @shop=Ecstore::Shop.new(params[:shop])

	shop_id=params[:shop][:shop_id]

       if @shop.save
	redirect_to "/shopinfos/my_goods?shop_id="+shop_id
       end
  end


def my_shop

   shop_id=params[:shop_id]
   shop=Ecstore::Shop.where(:shop_id=>shop_id)
    len =shop.length
     if len.to_i==0
	redirect_to "/shopinfos/register?shop_id="+shop_id
	else
	redirect_to "/shopinfos/my_goods?shop_id="+shop_id
     end
	

end


  def show_goods
   supplier_id=78
    @supplier = Ecstore::Supplier.find(supplier_id)
   @goods =  Ecstore::Good.where(:supplier_id=>"77")
   if params[:cat_id]
     @goods =  Ecstore::Good.where(:supplier_id=>"77",:cat_id=>params[:cat_id])
   end
   @recommend_user = session[:recommend_user]

   if @recommend_user==nil &&  params[:wechatuser]
     @recommend_user = params[:wechatuser]
   end
   if @recommend_user
     member_id =-1
     if signed_in?
       member_id = @user.member_id
     end
     now  = Time.now.to_i
     Ecstore::RecommendLog.new do |rl|
       rl.wechat_id = @recommend_user
       #  rl.goods_id = @good.goods_id
       rl.member_id = member_id
       rl.terminal_info = request.env['HTTP_USER_AGENT']
       #   rl.remote_ip = request.remote_ip
       rl.access_time = now
     end.save
     session[:recommend_user]=@recommend_user
     session[:recommend_time] =now
   end

   render :layout=>@supplier.layout
  end

def add_goods

 ids = params[:selector_shop]
 shop_id=params[:shop_id]
  if !ids.nil?
 id_array = ids.split(",")

  
 for i in id_array
  
 @istrue = Ecstore::ShopsGood.where(:goods_id=>i)
     if !@istrue.nil?
       id_array.delete(i)
  
=begin     
     good =Ecstore::ShopsGood.new do |goo|
     goo.shop_id=1
     goo.goods_id=id

   end.save
=end
   
 end
 end
  id_array.each do |id|

     good =Ecstore::ShopsGood.new do |goo|
     goo.shop_id=1
     goo.goods_id=id

     end.save
   end


end

end

def my_goods

   @shop_id=params[:shop_id]

  goods = Ecstore::ShopsGood.where(:shop_id=>'1')
  m=nil
   @goods=nil  
   for i in goods 
    
	good =Ecstore::Good.where(:goods_id=>i.goods_id)
   if @goods.nil?
       @goods=good
    else 
   @goods=@goods+good
  
  end
   
    end

   supplier_id=78
  @supplier = Ecstore::Supplier.find(supplier_id)
  render :layout=>@supplier.layout
  end


def goods_details

   @shop_id=params[:shop_id]
   @user_id=params[:user_id]
   
   @good = Ecstore::Good.includes(:specs,:spec_values,:cat).where(:bn=>params[:id]).first

   return render "not_find_good",:layout=>"new_store" unless @good

  @recommend_user = session[:recommend_user]

   if @recommend_user==nil &&  params[:wechatuser]
    @recommend_user = params[:wechatuser]
   end
  if @recommend_user
     member_id =-1
     if signed_in?
       member_id = @user.member_id
     end
     now  = Time.now.to_i
      Ecstore::RecommendLog.new do |rl|
       rl.wechat_id = @recommend_user
       rl.goods_id = @good.goods_id
       rl.member_id = member_id
       rl.terminal_info = request.env['HTTP_USER_AGENT']
    #   rl.remote_ip = request.remote_ip
       rl.access_time = now
     end.save
    session[:recommend_user]=@recommend_user
    session[:recommend_time] =now
   end
  tag_name = params[:tag]
   @tag = Ecstore::TagName.find_by_tag_name(tag_name)

   @cat = @good.cat
   @recommend_goods = []
   if @cat.goods.size >= 4
     @recommend_goods =  @cat.goods.where("goods_id <> ?", @good.goods_id).order("goods_id desc").limit(4)
   else
     @recommend_goods += @cat.goods.where("goods_id <> ?", @good.goods_id).limit(4).to_a
     @recommend_goods += @cat.parent_cat.all_goods.select{|good| good.goods_id != @good.goods_id }[0,4-@recommend_goods.size] if @cat.parent_cat && @recommend_goods.size < 4
     @recommend_goods.compact!
     if @cat.parent_cat.parent_cat && @recommend_goods.size < 4
       count = @recommend_goods.size
       @recommend_goods += @cat.parent_cat.parent_cat.all_goods.select{|good| good.goods_id != @good.goods_id }[0,4-count]
     end
end

   @supplier_id =  @shop_id
   
     @supplier  =  Ecstore::Supplier.find(78)
     render :layout=>@supplier.layout


end





end



