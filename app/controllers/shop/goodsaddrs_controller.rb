#encoding:utf-8
class Shop:: GoodsaddrsController < ApplicationController

 layout "shop"


def addr_detail
  @shop_id =params[:shop_id]
  @user_id =params[:user_id]

  @manco_title="地址信息"
  @addr = Ecstore::Visitor.find(@user_id)
  #supplier_id=params[:supplier_id]
  @supplier = Ecstore::Supplier.find(78)
  @method = :put
   render :layout=>'shop'
end

def edit_addr

 @visitor = Ecstore::Visitor.find(params[:id])

 if  @visitor.update_attributes(params[:visitor])
 respond_to do |format|
   format.js
   format.html { redirect_to "/goodsaddrs/addr_detail?user_id"+params[:id]+"&shop_id=" }
 end
   else
      render 'error.js' #, status: :unprocessable_entity
   end
  end




end


