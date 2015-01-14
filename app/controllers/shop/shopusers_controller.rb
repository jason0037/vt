# encoding: utf-8
class Shop::ShopusersController < ApplicationController
  before_filter :find_shop_user
  layout "shop"

  def index
    if @user.nil?
      redirect_to "/shop/shopinfos"
    end
    @shop_title="账户中心"
    if params[:shop_id]
      @shop_id = params[:shop_id]       
    else
      @shop_id = @user.member_id
    end

    @shop=Ecstore::Shop.find_by_shop_id(@shop_id)    
  end

 def clients
   @shop_title="客户管理"
   @shop_id = @user.member_id
   @shop_clients=Ecstore::ShopClient.where(:shop_id=>@user.member_id)

 end


end


