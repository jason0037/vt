#encoding:utf-8
class Shop:: ShopinfosController < ApplicationController
  before_filter :find_shop_user
  require 'net/http'
  require 'nokogiri'
  require 'open-uri'

  layout "shop"

   def goods_destroy
    @shop_id = @user.member_id
    @goods_id = params[:goods_id]

    Ecstore::ShopsGood.where(:shop_id=>@shop_id,:goods_id=>@goods_id).delete_all

   redirect_to '/shop/shopinfos/my_goods'
  end


  def new
    if @user
      @shop=Ecstore::Shop.find_by_shop_id(@user.member_id)
      if @shop
        redirect_to "/shop/shopinfos"
      end
    else
     redirect_to "/auto_login?id=78&supplier_id=78&platform=mobile&return_url=/shop/shopinfos/new"
    end

  end

  def index
    if @user

      @headimgurl = @user.weixin_headimgurl
      if @headimgurl.nil?
        @headimgurl ='http://vshop.trade-v.com/assets/trade-vLogo.jpg'
      end
        page= Nokogiri::HTML(open(@headimgurl))
        @shop=Ecstore::Shop.find_by_shop_id(@user.member_id)
      if @shop
       name=@shop.shop_name
        @shop_title="来自#{name}的微商店"
      end
    else
     redirect_to "/auto_login?id=78&supplier_id=78&platform=mobile&return_url=/shop/shopinfos"
    end
  end


  def create

    if params[:parent]
      params[:shop].merge!(:parent=>params[:parent])
    end
    @member = Ecstore::User.where(:member_id=>@user.member_id).first
    @member.update_attributes(:mobile=>params[:shop][:mobile],:email=>params[:shop][:email])

    params[:shop].merge!(:shop_id=>@user.member_id,:shop_logo=>@user.weixin_headimgurl)
    @shop=Ecstore::Shop.new(params[:shop])    

    if @shop.save
      shop_id=@shop.shop_id
      redirect_to "/shop/shopinfos/my_goods"
    else
      redirect_to "/shop/shopinfos/new"
    end
  end


  def myshop   

    if params[:shop_id]
      @shop_id = params[:shop_id]
    else
      redirect_to "/shop/shopinfos"
    end

    if @user
      if @user.member_id != @shop_id
        shop_client = Ecstore::ShopClient.where(:member_id=>@user.member_id,:shop_id=>@shop_id)
        if shop_client.size ==0
          Ecstore::ShopClient.new do |sc|
            sc.member_id = @user.member_id
            sc.shop_id = @shop_id
          end.save
        end
      end
    end

    @shop= Ecstore::Shop.find_by_shop_id(@shop_id)
    @share_desc =@shop.shop_intro
    @shop_title = @shop.shop_name

    @shop_goods = Ecstore::ShopsGood.where(:shop_id=>@shop_id)

    # good=nil
    # @shop_goods.each  do |go|
    #   if go.good_status=="0"
    #   go.update_attribute(:good_status,"1")   ###讲商品状态设置为上架
    #  end
    # end
    # goods= Ecstore::ShopsGood.where(:shop_id=>@shop_id,:good_status=>"1")    
  end


  def show_goods
    @shop_title = '店铺商品挑选'

    sql = 'SELECT st1.cat_name, st1.cat_id,st1.parent_id,st1.cat_path FROM mdk.sdb_b2c_goods_cat st1 INNER JOIN mdk.sdb_b2c_goods st2 ON (st1.cat_id = st2.cat_id) GROUP BY st1.cat_id HAVING COUNT(*) > 1 order by cat_path'
    @category = ActiveRecord::Base.connection.execute(sql)

  #  brand_id = params[:brand]
    cat_id = params[:cat_id]

    if cat_id.nil?
      cat_id = 561 #德国香肠
    end

    @shop_id = @user.member_id
    @shop=Ecstore::Shop.find_by_shop_id(@shop_id)
   
    @goods =  Ecstore::Good.where("marketable='true' and cat_id=?",cat_id)

  end


  def add_goods
    ids = params[:goods_id]
    
    if ! ids.nil?
      ids.each do |id|        

        if  Ecstore::ShopsGood.where(:goods_id=>id,:shop_id=>@user.member_id).size==0
          Ecstore::ShopsGood.new do |goo|
            goo.shop_id=@user.member_id
            goo.goods_id=id
            goo.uptime=Time.now
          end.save
        end
      end
    end
    redirect_to "/shop/shopinfos/my_goods?shop_id=#{@user.member_id}"
  end

  def my_goods
    @shop_title="商品中心"

     if @user
      @shop_id = @user.member_id
    else
      redirect_to "/shop/shopinfos"
    end

    @shop= Ecstore::Shop.find_by_shop_id(@shop_id)

    @shop_goods = Ecstore::ShopsGood.where(:shop_id=> @shop_id)  

  end

  def goods_details
    @shop_id=params[:shop_id]
    @shop=Ecstore::Shop.find_by_shop_id(@shop_id)
    @shop_title="来自#{@shop.shop_name}的微商店"

    if session[:shop_id].nil?
      session[:shop_id]=@shop_id
    end

     if @user.nil?
      @login = 'login'
    else
      @login=''
      if @user.member_id != @shop_id
        shop_client = Ecstore::ShopClient.where(:member_id=>@user.member_id,:shop_id=>@shop_id)
        if shop_client.size ==0
          Ecstore::ShopClient.new do |sc|
            sc.member_id = @user.member_id
            sc.shop_id = @shop_id
          end.save
        end
      end
    end
   
    @good = Ecstore::Good.includes(:specs,:spec_values,:cat).where(:bn=>params[:id]).first
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

  def details_trade
    @shop_id=params[:shop_id]
    @user_id=params[:user_id]
    name=Ecstore::Shop.find_by_shop_id(@shop_id).shop_name
    @good = Ecstore::Good.includes(:specs,:spec_values,:cat).where(:bn=>params[:id]).first
    @shop_title=@good.name
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
    if @user.nil?
       redirect_to "/shop/shopinfos"
    end

    @shop_title="订单管理"

    @shop= Ecstore::Shop.find_by_shop_id(@shop_id)

    if params[:shop_id] #微店客户查看订单
      @shop_id = params[:shop_id]
      @orders = Ecstore::Order.where(:shop_id=>@shop_id,:member_id=> @user.member_id).order("createtime desc")
    else  #店长查看订单
      @shop_id = @user.member_id
      @orders = Ecstore::Order.where(:shop_id=>@shop_id).order("createtime desc")
    end  
 end


end


