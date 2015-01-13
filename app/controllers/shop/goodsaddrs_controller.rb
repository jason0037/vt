#encoding:utf-8
class Shop:: GoodsaddrsController < ApplicationController
  before_filter :find_shop_user
 layout "shop"




  def  new_addr
    @shop_title="地址管理"
    user_id=params[:user_id]
    @visitors=Ecstore::Visitor.find(user_id)
 if params[:return_url]
      @return_url=params[:return_url]
    end
  @action_url="add"
  end


  def add
    @visitor = Ecstore::Visitor.find(params[:user_id])
 if  @visitor.update_attributes(params[:visitor])
    if params[:return_url]
      redirect_to params[:return_url] +"&user_id=#{params[:user_id]}"
    end
  end
  end
def addr_detail
  @shop_id =params[:shop_id]
  addr_id =params[:addr_id]

  @shop_title="地址信息"
  @addr = Ecstore::Visitor.find(addr_id)
  #supplier_id=params[:supplier_id]

  @method = :put
   render :layout=>'shop'
end

def edit_addr

 @visitor = Ecstore::Visitor.find(params[:id])

 if  @visitor.update_attributes(params[:visitor])
 respond_to do |format|
   format.js
   format.html { redirect_to "/shop/goodsaddrs/addr_detail?user_id="+params[:id]+"&shop_id=" +params[:shop_id]}
 end
   else
      render 'error.js' #, status: :unprocessable_entity
   end
  end




end


