# encoding: utf-8
class Shop::ShopusersController < ApplicationController
  before_filter :find_shop_user
  layout "shop"

  def index
    @shop=Ecstore::Shop.find_by_shop_id(params[:shop_id])
    if params[:user_id]
       @users=params[:user_id]
       @shop_title="个人中心"
    else

   @shop_title="自贸平台管理"
    end
  end

 def user
   @shop_title="会员管理"
    @shop_id=params[:shop_id]
   @shopuser=Ecstore::Visitor.where(:shop_id=>@shop_id)


 end


end


