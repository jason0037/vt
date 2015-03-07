# encoding: utf-8
class Shop::ShopusersController < ApplicationController

  layout "shop"

 

  def index
    if @user.nil?
      redirect_to "/shop/shopinfos"
    end
    @shop_title="管理中心"
    if params[:shop_id]
      shop_id = params[:shop_id]
    else
      shop_id =Ecstore::Shop.find_by_member_id(@user.member_id).shop_id
    end

     @shop= Ecstore::Shop.where(:shop_id=>shop_id,:status=>1).first

    @share_for_shop = 0
    @share_for_sale = 0
    @share_for_promotion = 0



      @share = Ecstore::Order.all(:conditions => "shop_id = #{ shop_id} and orderstatus='true'",
                                 :select => "SUM(share_for_sale) share_sale ,SUM(final_amount) final_amount",:group=>"shop_id").first
      if @share
        @share_for_sale = @share.share_sale
      end
      if @shop.parent.nil?
        shop_ids = 0
        results = Ecstore::Shop.where(:parent=>shop_id)

        if results
          results.each do |row|
            shop_ids=+ row.shop_id

          end
        end

        @share_for_shop = Ecstore::Order.all(:conditions => "shop_id in (#{shop_ids}) and orderstatus='true'",

                                             :select => "SUM(share_for_shop) share_shop, shop_id",:group=>"shop_id")

      end




  end

 def clients
   @shop_title="客户管理"
   shop_id = params[:shop_id]

   @shop_clients=Ecstore::ShopClient.where(:shop_id=>shop_id).order("created_at desc")

 end

  def user
    @shop_title="用户信息"

    member_id=params[:member_id]
    @shop= Ecstore::Shop.find_by_member_id(member_id)
   unless @shop
     redirect_to "/shop/shopinfos/new"
   end
  end

  def edit
      @shop=Ecstore::Shop.find(params[:shop_id])
     if  @shop.update_attributes(params[:shop])
         render "edit"
     end

  end
  def branch
    @shop_title="分店中心"
     @results = Ecstore::Shop.all(:conditions =>"parent =#{params[:shop_id]}")
     end




  def share
    if @user.nil?
      redirect_to "/shop/shopinfos"
    end

    @shop_title="我的收益"
    if params[:shop_id]
      shop_id = params[:shop_id]
    else
      shop_id =Ecstore::Shop.find_by_member_id(@user.member_id).shop_id
    end

    @shop=Ecstore::Shop.find_by_shop_id(shop_id)

    @share_for_shop = 0
    @share_for_sale = 0
    @share_for_promotion = 0

    if @user.member_id.to_s==@shop.member_id.to_s

      share = Ecstore::Order.all(:conditions => "shop_id = #{ shop_id} and orderstatus='true'",
                  :select => "SUM(share_for_sale) share_sale",:group=>"shop_id").first
      if share
        @share_for_sale = share.share_sale
      end
    if @shop.parent.nil?
        shop_ids = 0
        # results = Ecstore::Shop.find_by_parent(shop_id)
        # if results
        #   results.each(:as => :hash) do |row|
        #     shop_ids= row["shop_id"]
        #   end
        # end
        results = Ecstore::Shop.where(:parent=>shop_id)

        if results
          results.each do |row|
            shop_ids=+ row.shop_id

          end
        end
        @share_for_shop = Ecstore::Order.all(:conditions => "shop_id in (#{shop_ids}) and orderstatus='true'",
                  :select => "SUM(share_for_shop) share_shop, shop_id",:group=>"shop_id")
    end
    else
      share = Ecstore::Order.all(:conditions => "shop_id = #{shop_id} and member_id=#{@user.member_id} and orderstatus='true'",
          :select => "SUM(share_for_promotion) share_promotion",:group=>"shop_id,member_id").first
      if share
        @share_for_promotion = share.share_promotion
      end

    end

  end

  def delete
    shop_id=params[:shop_id]
    @shop=Ecstore::Shop.find(shop_id)
    @shop_user=Ecstore::ShopClient.where(:shop_id=>shop_id)
    @shop_order=Ecstore::Order.where(:shop_id=>shop_id)
    @shop_title="申请关店"
  end

  def submit_delete
    shop_id=params[:shop_id]
    @shop=Ecstore::Shop.find(shop_id)
    @shop.update_attribute(:status ,-2)


  end

end


