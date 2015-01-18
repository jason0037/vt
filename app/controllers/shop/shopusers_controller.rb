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

      @share_for_sale = Ecstore::Order.all(:conditions => "shop_id = #{ @shop_id}",
                  :select => "SUM(share_for_sale) share_sale",:group=>"shop_id").first.share_sale

      if @shop.parent.nil?
        shop_ids = 0
        results = Ecstore::Shop.find_by_parent(@shop_id)
        if results
          results.each(:as => :hash) do |row|
            shop_ids= row["shop_id"]
          end
        end

        @share_for_shop = Ecstore::Order.all(:conditions => "shop_id in (#{shop_ids}) ",
                  :select => "SUM(share_for_shop) share_shop, shop_id",:group=>"shop_id")
      end

    else
      @share_for_promotion = Ecstore::Order.all(:conditions => "shop_id = #{@shop_id} and member_id=#{@user.member_id}",
          :select => "SUM(share_for_promotion) share_promotion",:group=>"shop_id,member_id").first.share_promotion
    end
    
  end


end


