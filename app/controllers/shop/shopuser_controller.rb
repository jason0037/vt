class Shop::ShopuserController < ApplicationController
  layout "shop"

  def index
    @shop=Ecstore::Shop.find_by_shop_id(params[:shop_id])
   @shop_title="自贸平台管理"
  end
end
