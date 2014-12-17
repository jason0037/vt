#encoding:utf-8
class Shop:: GoodsaddrsController < ApplicationController
  before_filter :find_shop_user
 layout "shop"




  def  new_addr

 if params[:return_url]
      @return_url=params[:return_url]
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
   format.html { redirect_to "/goodsaddrs/addr_detail?user_id="+params[:id]+"&shop_id=" +params[:shop_id]}
 end
   else
      render 'error.js' #, status: :unprocessable_entity
   end
  end




end


