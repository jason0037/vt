#encoding:utf-8
class Shop:: GoodsaddrsController < ApplicationController

 layout "tradev"


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
return render :text=>params[:visitor]
 @addr = Ecstore::Visitor.find(params[:id])
   if @addr.update_attributes(params[:addr])
      respond_to do |format|
       format.js
       format.html { redirect_to "/orders/new_mobile?platform=mobile" }
     end
   else
     render 'error.js' #, status: :unprocessable_entity
   end

end


end
