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


  def share
    if @user.nil?
      redirect_to "/shop/shopinfos"
    end

    @shop_title="我的收益"
    if params[:shop_id]
      @shop_id = params[:shop_id]       
    else
      @shop_id = @user.member_id
    end

    @shop=Ecstore::Shop.find_by_shop_id(@shop_id)

    @share_for_shop = 0
    @share_for_sale = 0
    @share_for_promotion = 0

    if @user.member_id.to_s==@shop_id.to_s
      Ecstore::order.where().

      if @shop.parent.nil?

      end

    else

    end
    
  end


end


