#encoding:utf-8
class Shop:: ShopinfosController < ApplicationController

  require 'net/http'
  require 'nokogiri'
  require 'open-uri'

  layout "shop"

  def goods_destroy
    Ecstore::ShopsGood.where(:shop_id=> params[:shop_id],:goods_id=> params[:goods_id]).delete_all

    if params[:platform]=="mygood"
       render "destroy"
    else
      redirect_to '/shop/shopinfos/my_goods'
    end

  end

  def new
    if @user
      @shop=Ecstore::Shop.find_by_member_id(@user.member_id)
      if @shop
        redirect_to "/shop/shopinfos"
      end
    else
     redirect_to "/auto_login?id=78&supplier_id=78&platform=mobile&return_url=/shop/shopinfos/new"
    end

  end

  def index


    if @user
      @shop = Ecstore::Shop.where(:member_id=>@user.member_id).first
      if @shop
        @headimgurl =  @shop.shop_logo
        @shop_title= @shop.shop_name
      else
        @headimgurl = @user.weixin_headimgurl
      end
     if @headimgurl
      page= Nokogiri::HTML(open(@headimgurl))
     end
    else
     redirect_to "/auto_login?id=78&supplier_id=78&platform=mobile&return_url=/shop/shopinfos"
    end
  end

  def fendian
    @shop=Ecstore::Shop.find(params[:shop_id])

    if @shop.permission_branch=="-1"
      @shop.update_attributes(:permission_branch=>"0")
    end

  end

  def create

    if params[:parent]

       @shop_status= Ecstore::Shop.find_by_parent(params[:parent])    ##查找当前父类的店铺订单是后过200
       if @shop_status.permission_branch=="1"
         params[:shop].merge!(:parent=>params[:parent])
       end
    end
    @member = Ecstore::User.where(:member_id=>@user.member_id).first
    @member.update_attributes(:mobile=>params[:shop][:mobile],:email=>params[:shop][:email])

    params[:shop].merge!(:member_id=>@user.member_id,:shop_logo=>@user.weixin_headimgurl)
    @shop=Ecstore::Shop.new(params[:shop])    

    if @shop.save

      @shop_log =Ecstore::ShopLog.new do |log|
        log.datetime=Time.now
        log.shop_id=@shop.shop_id
        log.shop_ip=request.remote_ip
      end.save
      redirect_to "/shop/shopinfos"
    else
      redirect_to "/shop/shopinfos/new"
    end
  end

  def myshop   
    if params[:shop_id]
      shop_id = params[:shop_id]
    else
      redirect_to "/shop/shopinfos"
    end

    @shop = Ecstore::Shop.where(:shop_id=>shop_id,:status=>1).first
    if @shop

       if @user
        if @user.member_id != @shop.member_id
          shop_client = Ecstore::ShopClient.where(:member_id=>@user.member_id,:shop_id=>shop_id)
          if shop_client.size ==0
            Ecstore::ShopClient.new do |sc|
              sc.member_id = @user.member_id
              sc.shop_id = shop_id
            end.save
          end
        end
      end

      @share_desc = @shop.shop_intro
      @shop_title = @shop.shop_name
      @shop_goods = Ecstore::ShopsGood.where(:shop_id=>shop_id)

      # good=nil
      # @shop_goods.each  do |go|
      #   if go.good_status=="0"
      #   go.update_attribute(:good_status,"1")   ###讲商品状态设置为上架
      #  end
      # end
      # goods= Ecstore::ShopsGood.where(:shop_id=>@shop_id,:good_status=>"1") 
    else   
       redirect_to "/shop/shopinfos" 
    end
  end

  def show_goods
    @shop_title = '店铺商品挑选'
    supplier_id= params[:supplier_id]
   #sql = 'SELECT st1.cat_name, st1.cat_id,st1.parent_id,st1.cat_path FROM mdk.sdb_b2c_goods_cat st1 INNER JOIN mdk.sdb_b2c_goods st2 ON (st1.cat_id = st2.cat_id) GROUP BY st1.cat_id HAVING COUNT(*) > 1 order by cat_path'
 # @category = ActiveRecord::Base.connection.execute(sql)
  if  supplier_id
    @category = Ecstore::Good.all(:conditions => "supplier_id=#{supplier_id}",
                                  :select => "count(*) sum ,cat_id",:group=>"cat_id")
      else
        @sup = Ecstore::Good.all(:conditions => "shopstatus = true",
                                 :select => "count(*) sum ,supplier_id",:group=>"supplier_id")

      end
    #  brand_id = params[:brand]
    cat_id = params[:cat_id]
    member_id = @user.member_id
    @shop=Ecstore::Shop.find_by_member_id(member_id)
    @goods=""
   if supplier_id
    @goods =  Ecstore::Good.where("marketable='true' and shopstatus='true' and supplier_id=?",supplier_id )
     end
   if  cat_id
     @goods =  Ecstore::Good.where("marketable='true' and shopstatus='true' and cat_id=?",cat_id)
  end
  end
  def add_goods
   @goods_id = params[:goods_id]
    supplier_id= params[:supplier_id]
    shop_id= params[:shop_id]

    @count = Ecstore::ShopsGood.all(:conditions => "shop_id = #{shop_id}",
                             :select => "count(*) sum, supplier_id ",:group=>"supplier_id")
    if  @count.size <3                     ###判断当供应商个数小于3执行添加,但是当添加第3个供应商后 执行elsif去查找是否第3个供应商的的supplier_id存在店铺表中
       if  Ecstore::ShopsGood.where(:goods_id=>@goods_id,:shop_id=>shop_id).size==0
               Ecstore::ShopsGood.new do |goo|
                goo.shop_id=shop_id
                goo.goods_id=@goods_id
                goo.supplier_id=supplier_id
                goo.uptime=Time.now
               end.save
      end
   elsif  Ecstore::ShopsGood.where(:supplier_id=>supplier_id ).count>0
       if  Ecstore::ShopsGood.where(:goods_id=>@goods_id,:shop_id=>shop_id).size==0
           Ecstore::ShopsGood.new do |goo|
           goo.shop_id=shop_id
           goo.goods_id=@goods_id
           goo.supplier_id=supplier_id
           goo.uptime=Time.now
         end.save
       end

   else
     return render "adderror"
   end

    else
      redirect_to "/shop/shopinfos/my_goods?shop_id=#{shop_id}"
    end

  def my_goods
    @shop_title="商品中心"

     if @user
      member_id = @user.member_id
    else
      redirect_to "/shop/shopinfos"
    end

    @shop= Ecstore::Shop.find_by_member_id(member_id)

    @shop_goods = Ecstore::ShopsGood.where(:shop_id=> @shop.shop_id)

  end

  def goods_details
    shop_id=params[:shop_id]
    @shop=Ecstore::Shop.find_by_shop_id(shop_id)
    @shop_title="来自#{@shop.shop_name}的微商店"

    if session[:shop_id].nil?
      session[:shop_id]=shop_id
    end

     if @user.nil?
      @login = 'login'
    else
      @login=''
      if @user.member_id != @shop.member_id
        shop_client = Ecstore::ShopClient.where(:member_id=>@user.member_id,:shop_id=> @shop.shop_id)
        if shop_client.size ==0
          Ecstore::ShopClient.new do |sc|
            sc.member_id = @user.member_id
            sc.shop_id = shop_id
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
    shop_id= params[:shop_id]
    @user_id=params[:user_id]
    @shop=Ecstore::Shop.find_by_shop_id(shop_id)
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
      @shop_id=params[:shop_id]
     @shop= Ecstore::Shop.find_by_shop_id(@shop_id)

    if params[:shop_id] #微店客户查看订单
      @shop_id = params[:shop_id]
      @orders = Ecstore::Order.where(:shop_id=>@shop_id,:member_id=> @user.member_id).order("createtime desc")
    else  #店长查看订单
      @shop_id =Ecstore::Shop.find_by_member_id(@user.member_id).shop_id
      @orders = Ecstore::Order.where(:shop_id=>@shop_id,:orderstatus=>"true").order("createtime desc")
    end  
 end

  def delete_order
     order_id=params[:order_id]
     @order=Ecstore::Order.find(order_id)
     if @order.update_attributes(:orderstatus=>"false")
    render "delete_order"
     else

     render "error"

     end

    end

end


