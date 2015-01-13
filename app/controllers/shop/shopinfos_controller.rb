#encoding:utf-8
class Shop:: ShopinfosController < ApplicationController
  before_filter :find_shop_user
  require 'net/http'
  require 'nokogiri'
  require 'open-uri'

  layout "shop"

  def index
    if @user

      headimgurl = @user.weixin_headimgurl
      if headimgurl.nil?
        headimgurl ='http://www.trade-v.com/assets/trade-vLogo.jpg'
      end
        page= Nokogiri::HTML(open(headimgurl))
        @shop=Ecstore::Shop.find_by_shop_id(@user.member_id)
      if @shop
       name=@shop.shop_name
        @shop_title="来自#{name}的微商店"
      end
    else
     redirect_to "/auto_login?id=78&supplier_id=78&platform=mobile&return_url=/shopinfos"
      end
    end


  def create

    @member = Ecstore::User.where(:member_id=>@user.member_id).first
    @member.update_attributes(:mobile=>params[:shop][:mobile],:email=>params[:shop][:email])

    params[:shop].merge!(:shop_id=>@user.member_id,:shop_logo=>@user.weixin_headimgurl)
    @shop=Ecstore::Shop.new(params[:shop])    

    if @shop.save
      shop_id=@shop.shop_id
      redirect_to "/shop/shopinfos/my_goods?shop_id=#{shop_id}"
    else
      redirect_to "/shop/shopinfos/new"
    end
  end


  def myshop
    @shop_id=params[:shop_id]
    account_id=@shop_id
    login_name=Ecstore::Account.find(account_id).login_name


    @followers = Ecstore::WechatFollower.find_by_openid(login_name)


    good=nil
    shopgood= Ecstore::ShopsGood.where(:shop_id=>@shop_id)

    shopgood.each  do |go|
      if go.good_status=="0"
      go.update_attribute(:good_status,"1")   ###讲商品状态设置为上架

     end
    end

goods= Ecstore::ShopsGood.where(:shop_id=>@shop_id,:good_status=>"1")
    @goods_store=nil
    for i in goods

      good =Ecstore::Good.where(:goods_id=>i.goods_id)
      if  @goods_store.nil?
        @goods_store=good
      else
        @goods_store= @goods_store+good

      end

    end
   @shop= Ecstore::Shop.find_by_shop_id(@shop_id)
    if @shop
    name=@shop.shop_name
   @shop_title="来自#{name}的微商店"
    end
    end





  def show_goods

    brand_id = params[:brand]
    cat_id = params[:cat_id]
    if brand_id.nil?
      brand_id = 138
    end

    @shop=Ecstore::Shop.find_by_shop_id(params[:shop_id])
    @goods =  Ecstore::Good.where("marketable='true' and brand_id=?",brand_id)

    if params[:cat_id]
      @goods =  Ecstore::Good.where("marketable='true' and brand_id=? and cat_id=?",brand_id,cat_id)
    end
    @recommend_user = session[:recommend_user]


    if @recommend_user==nil &&  params[:wechatuser]
      @recommend_user = params[:wechatuser]
    end
    if @recommend_user
      member_id =-1
      if signed_in?
        member_id = @user.member_id
      end
      now  = Time.now.to_i
      Ecstore::RecommendLog.new do |rl|
        rl.wechat_id = @recommend_user
        #  rl.goods_id = @good.goods_id
        rl.member_id = member_id
        rl.terminal_info = request.env['HTTP_USER_AGENT']
        #   rl.remote_ip = request.remote_ip
        rl.access_time = now
      end.save
      session[:recommend_user]=@recommend_user
      session[:recommend_time] =now
    end


  end


  def add_goods

    ids = params[:selector_shop]
    @shop_id=params[:shop_id]
    if !ids.nil?
      id_array = ids.split(",")

      id_array.each do |id|

        if  Ecstore::ShopsGood.find_by_goods_id(id).nil?
          good =Ecstore::ShopsGood.new do |goo|
            goo.shop_id=@shop_id
            goo.goods_id=id
            goo.uptime=Time.now

          end.save
        end
      end

    end


  end

  def my_goods
    @shop_title="商品中心"

    @shop_id=params[:shop_id]

    goods = Ecstore::ShopsGood.where(:shop_id=> @shop_id)

    m=nil
    @goods_store=nil
    for i in goods

      good =Ecstore::Good.where(:goods_id=>i.goods_id)
      if  @goods_store.nil?
        @goods_store=good
      else
        @goods_store= @goods_store+good

      end

    end


  end


  def goods_details


    @shop_id=params[:shop_id]
    @user_id=params[:user_id]
    name=Ecstore::Shop.find_by_shop_id(@shop_id).shop_name
    @good = Ecstore::Good.includes(:specs,:spec_values,:cat).where(:bn=>params[:id]).first
    @shop_title="欢迎来到#{name}的微商店"
    return render "not_find_good",:layout=>"shop" unless @good
    #visitors=Ecstore::Visitor
    @recommend_user = session[:recommend_user]

    if @recommend_user==nil &&  params[:wechatuser]
      @recommend_user = params[:wechatuser]
    end
    if @recommend_user
      member_id =-1
      if signed_in?
        member_id = @user.member_id
      end
      now  = Time.now.to_i
      Ecstore::RecommendLog.new do |rl|
        rl.wechat_id = @recommend_user
        rl.goods_id = @good.goods_id
        rl.member_id = member_id
        rl.terminal_info = request.env['HTTP_USER_AGENT']
        #   rl.remote_ip = request.remote_ip
        rl.access_time = now
      end.save
      session[:recommend_user]=@recommend_user
      session[:recommend_time] =now
    end
    tag_name = params[:tag]
    @tag = Ecstore::TagName.find_by_tag_name(tag_name)

    @cat = @good.cat
    @recommend_goods = []
    if @cat.goods.size >= 4
      @recommend_goods =  @cat.goods.where("goods_id <> ?", @good.goods_id).order("goods_id desc").limit(4)
    else
      @recommend_goods += @cat.goods.where("goods_id <> ?", @good.goods_id).limit(4).to_a
      @recommend_goods += @cat.parent_cat.all_goods.select{|good| good.goods_id != @good.goods_id }[0,4-@recommend_goods.size] if @cat.parent_cat && @recommend_goods.size < 4
      @recommend_goods.compact!
      if @cat.parent_cat.parent_cat && @recommend_goods.size < 4
        count = @recommend_goods.size
        @recommend_goods += @cat.parent_cat.parent_cat.all_goods.select{|good| good.goods_id != @good.goods_id }[0,4-count]
      end
    end





  end

  def details_trade
    @shop_id=params[:shop_id]
    @user_id=params[:user_id]
    name=Ecstore::Shop.find_by_shop_id(@shop_id).shop_name
    @good = Ecstore::Good.includes(:specs,:spec_values,:cat).where(:bn=>params[:id]).first
    @shop_title="贸威商品详细"
    return render "not_find_good",:layout=>"shop" unless @good

    @recommend_user = session[:recommend_user]

    if @recommend_user==nil &&  params[:wechatuser]
      @recommend_user = params[:wechatuser]
    end
    if @recommend_user
      member_id =-1
      if signed_in?
        member_id = @user.member_id
      end
      now  = Time.now.to_i
      Ecstore::RecommendLog.new do |rl|
        rl.wechat_id = @recommend_user
        rl.goods_id = @good.goods_id
        rl.member_id = member_id
        rl.terminal_info = request.env['HTTP_USER_AGENT']
        #   rl.remote_ip = request.remote_ip
        rl.access_time = now
      end.save
      session[:recommend_user]=@recommend_user
      session[:recommend_time] =now
    end
    tag_name = params[:tag]
    @tag = Ecstore::TagName.find_by_tag_name(tag_name)

    @cat = @good.cat
    @recommend_goods = []
    if @cat.goods.size >= 4
      @recommend_goods =  @cat.goods.where("goods_id <> ?", @good.goods_id).order("goods_id desc").limit(4)
    else
      @recommend_goods += @cat.goods.where("goods_id <> ?", @good.goods_id).limit(4).to_a
      @recommend_goods += @cat.parent_cat.all_goods.select{|good| good.goods_id != @good.goods_id }[0,4-@recommend_goods.size] if @cat.parent_cat && @recommend_goods.size < 4
      @recommend_goods.compact!
      if @cat.parent_cat.parent_cat && @recommend_goods.size < 4
        count = @recommend_goods.size
        @recommend_goods += @cat.parent_cat.parent_cat.all_goods.select{|good| good.goods_id != @good.goods_id }[0,4-count]
      end
    end




  end




 def myorder
   shop_id=params[:shop_id]
   @shop_title="订单管理"
   if params[:user_id]
     @user_id= params[:user_id]
     @orders = Ecstore::Order.where(:supplier_id=>shop_id,:member_id=> @user_id).order("createtime desc")

   end
   @orders = Ecstore::Order.where(:supplier_id=>shop_id).order("createtime desc")
 end


end


