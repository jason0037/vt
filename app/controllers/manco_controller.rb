#encoding:utf-8
require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'open-uri'
class MancoController < ApplicationController

  layout "manco"
  def index

  end
  def city
    supplier_id=params[:supplier_id]
    @supplier = Ecstore::Supplier.find(supplier_id)
  end
  def main
    @manco_title="万家简介"
    supplier_id=params[:supplier_id]
    if @user
      @supplier = Ecstore::Supplier.find(supplier_id)
    else

      redirect_to "/auto_login?id=#{supplier_id}&supplier_id=#{supplier_id}&platform=mobile&return_url=/manco/main?supplier_id=#{supplier_id}"
    end
  end

  def history
      @manco_title="万家历程"
    supplier_id=params[:supplier_id]
    @supplier = Ecstore::Supplier.find(supplier_id)
  end

  def map
    supplier_id=params[:supplier_id]
    @manco_title="联系我们"
    @supplier = Ecstore::Supplier.find(supplier_id)

  end
  def show
    supplier_id=params[:supplier_id]
    @supplier = Ecstore::Supplier.find(supplier_id)
  end

  def find_manco
    @manco_title="我要发货"
    supplier_id = params[:supplier_id]
    if @user
    @supplier =Ecstore::Supplier.find(supplier_id)
    else

    redirect_to "/auto_login?id=#{supplier_id}&supplier_id=#{supplier_id}&platform=mobile&return_url=/manco/find_manco?supplier_id=#{supplier_id}"
    end

  end

  def user

    supplier_id = params[:supplier_id]
    if @user

      @supplier =Ecstore::Supplier.find(supplier_id)
    login_name=@user.login_name
    account_id=Ecstore::Account.find_by_sql(["select account_id from sdb_pam_account where login_name=?",login_name])
    @member=Ecstore::Member.find_by_sql(["select * from sdb_b2c_members where member_id=?",account_id])
   else
       redirect_to "/auto_login?id=#{supplier_id}&supplier_id=#{supplier_id}&platform=mobile&return_url=/manco/user?supplier_id=#{supplier_id}"
   end

  end


  def good_source
    @manco_title="发布货源小黑板"
    supplier_id = params[:supplier_id]
    @supplier =Ecstore::Supplier.find(supplier_id)
    @addr=Ecstore::MemberAddr.new
    account=@user.member_id
    @member= Ecstore::User.find_by_member_id(account)

  end

 def black_good_index
   @manco_title="货源小黑板"
   supplier_id = params[:supplier_id]
   if @user
   @supplier =Ecstore::Supplier.find(supplier_id)
      @good=Ecstore::BlackGood.paginate :page=>params[:page],        ###分页语句
                                :per_page =>5,              ###当前只显示一条
                                :conditions => ["cat_id=571"]    ####小黑板对应的类别为571
      @good =@good.where("downtime>UNIX_TIMESTAMP(now()) ")
   else


     redirect_to "/auto_login?id=#{supplier_id}&supplier_id=#{supplier_id}&platform=mobile&return_url=/manco/black_good_index?supplier_id=#{supplier_id}"
   end
 end

  def blackgood_add
    departure= params[:departure]
    arrival= params[:arrival]
    hour=params[:hour]
    goodsname=departure+"-"+arrival;
    @blackgood=Ecstore::BlackGood.new(params[:black_good]) do |sv|
       sv.name= goodsname
      sv.uptime=Time.now
       sv.downtime=Time.parse(params[:black_good][:downtime]).to_i+(hour.to_i)*3600

    end.save

    redirect_to "/manco/black_good_index?supplier_id=98"
  end
  def black_index
       @manco_title="车源小黑板"
    supplier_id = params[:supplier_id]
    if @user
    @supplier =Ecstore::Supplier.find(supplier_id)

    account=@user.member_id
    @member=   Ecstore::User.find_by_member_id(account)
      @good=Ecstore::Good.paginate :page=>params[:page],        ###分页语句
                                   :per_page => 5,              ###当前只显示一条
                                   :conditions => ["cat_id=571"]    ####小黑板对应的类别为571
    @good =@good.where("downtime>UNIX_TIMESTAMP(now()) ")
  else
  redirect_to "/auto_login?id=#{supplier_id}&supplier_id=#{supplier_id}&platform=mobile&return_url=/manco/black_index?supplier_id=#{supplier_id}"
  end
  end

  def blackboardfind_e

    @departure= params[:departure]
    @arrival= params[:arrival]
    goodsname=@departure+"-"+@arrival;
    @goods=Ecstore::Good.where(:name=>goodsname,:cat_id=>"570").first   ####万家线路图对应的类别为570
    if @goods.nil?
      @goodes="亲！万家物流暂时还没有开通该线路哦!"

    end

  end


  def choose_express
    @manco_title="落地配模式"
    supplier_id=params[:supplier_id]
    if @user


      @supplier = Ecstore::Supplier.find(supplier_id)
    else

      redirect_to "/auto_login?id=#{supplier_id}&supplier_id=#{supplier_id}&platform=mobile&return_url=/manco/express?supplier_id=#{supplier_id}"

    end
  end

  def local_express
    @manco_title="本地派送"
    supplier_id=params[:supplier_id]
    if @user
      @line_items.delete_all ###本地落地配服务

      @supplier = Ecstore::Supplier.find(supplier_id)
    else

      redirect_to "/auto_login?id=#{supplier_id}&supplier_id=#{supplier_id}&platform=mobile&return_url=/manco/express?supplier_id=#{supplier_id}"

    end
  end


  def l_express

    distribution=params[:distribution]
    if distribution=="l_self"
      @dis="本地自提"
    elsif distribution=="l_door"
      @dis="本地门对门"
     end
    @line_items.delete_all ###本地落地配服务
    @goods=Ecstore::Good.find_by_cat_id(Ecstore::GoodCat.find_by_cat_name(@dis).cat_id)


  end

 def express
   @manco_title="同业供配"
   supplier_id=params[:supplier_id]
   if @user
   @line_items.delete_all ###同业落地配服务

   @supplier = Ecstore::Supplier.find(supplier_id)
 else

   redirect_to "/auto_login?id=#{supplier_id}&supplier_id=#{supplier_id}&platform=mobile&return_url=/manco/express?supplier_id=#{supplier_id}"

 end
  end


  def new
    @good  =  Ecstore::Good.new

    @method = :post
    redirect_to '/manco/blackbord?supplier_id=98'
  end



  def blackbord
    @manco_title="车源信息"
    supplier_id = params[:supplier_id]
    if @user

      @supplier =Ecstore::Supplier.find(supplier_id)
       account=@user.member_id
       @member=   Ecstore::User.find_by_member_id(account)
      unless @member.name and @member.bank_info          ####判断逻辑不严谨
        redirect_to '/profile/mancouser?supplier_id=98'
      end
  else
    redirect_to "/auto_login?id=#{supplier_id}&supplier_id=#{supplier_id}&platform=mobile&return_url=/manco/blackbord?supplier_id=#{supplier_id}"
  end


end

  def blackbord_add
    @manco_title="发布车源信息"
    hour=params[:hour]
    @good = Ecstore::Good.new(params[:good]) do |ac|
            ac.bn="a098"+Time.now.strftime('%Y%m%d%H%M%S')
            ac.unit= "吨"
            ac.uptime=Time.now
            ac.downtime=Time.parse(params[:good][:downtime]).to_i+(hour.to_i)*3600

    end
    @good.save


    if @good.save
      specname=@good.name.gsub(/-/,',')
      spec_id =params[:spec_id]
      spec_id = Ecstore::Spec.where(:spec_name=>specname)
       bn =@good.bn
          @new_product = Ecstore::Product.find_by_bn(bn)
          if !@new_product.nil? && @new_product.persisted?
            @product = @new_product
          else
            @product = Ecstore::Product.new
            @product.bn = bn
          end

          @product.goods_id = @good.goods_id
          @product.name = @good.name
          # @product.store_time =
          @product.store = @good.store
          @product.cost= @good.cost
          @product.wholesale = @good.wholesale
          @product.bulk = @good.bulk
          @product.promotion=@good.promotion
          @product.price = @good.price
          @product.mktprice =@good.mktprice

          @product.save!

           Ecstore::GoodSpec.where(:product_id=>@product.product_id).delete_all
           spec_value_id= Ecstore::SpecValue.find_by_sql(["select spec_value_id from sdb_b2c_spec_values where spec_value=?and spec_id=?",specname,12])
           unless spec_value_id.nil?
                    Ecstore::SpecValue.new do |sv|
                      sv.spec_id=12
                      sv.spec_value =specname
                    end.save
           else

                sp_val_id = Ecstore::SpecValue.find_by_sql(["select spec_value_id from sdb_b2c_spec_values where spec_value=?and spec_id=?",specname,12])
               Ecstore::GoodSpec.new do |gs|
               gs.type_id =  @good.type_id
               gs.spec_id = 12
               gs.spec_value_id = sp_val_id
               gs.goods_id = @good.goods_id
               gs.product_id = @product.product_id
             end.save


          end

    else
    render "new"

    end
    redirect_to '/manco/black_index?supplier_id=98'
  end

  def manco_comment
       @manco_title="评论"
    supplier_id = params[:supplier_id]
    @supplier =Ecstore::Supplier.find(supplier_id)

  end





  def show_carblack
    @manco_title="车源小黑板"
    supplier_id = params[:supplier_id]
    @supplier =Ecstore::Supplier.find(supplier_id)
      id=params[:id]
    @good =Ecstore::Good.paginate :page=>params[:page],        ###分页语句
                                 :per_page => 5,              ###当前只显示一条
                                 :conditions => ["member_id=#{id}"]
     render :layout => @supplier.layout

  end

   def mancoluodipei

     @departure= params[:departure]
     @arrival= params[:arrival]
     distribution=params[:distribution]
      goods=@departure+"-"+@arrival;
     @goods=Ecstore::Good.where(:cat_id=>distribution,:name=>goods).first
      if @goods.nil?
         @goodes="亲！万家物流暂时还没有开通该线路哦!"

      end
     @catname=Ecstore::GoodCat.where(:cat_id=>distribution).first
   end



 def departure

   @way=params[:way]
   supplier_id = params[:supplier_id]
   @supplier =Ecstore::Supplier.find(supplier_id)
   if @way =="departure"
      @addrs =  @user.member_addrs
      @manco_title="装货地址"
      @def_addrs = @addrs.where(:addr_type=>1) || @addrs.first
   elsif  @way =="arrival"
     @manco_title="卸货地址"
     @addrs =  @user.member_addrs
     @def_addrs = @addrs.where(:addr_type=>0) || @addrs.first
     end
 end

def departure_edit
  @way=params[:way]

  if @way =="departure"
     @manco_title="修改装货地址"
  elsif  @way =="arrival"
    @manco_title="修改卸货地址"

  end
  supplier_id = params[:supplier_id]
  @supplier =Ecstore::Supplier.find(supplier_id)
  @addr = Ecstore::MemberAddr.find( params[:member_departure_id])
  @action_url="edit_addr"
  @method="post"
end

 def edit_addr
   @way=params[:way]
   @addr = Ecstore::MemberAddr.find(params[:addr][:id])
   if @addr.update_attributes(params[:addr])
     respond_to do |format|
       format.js
       format.html { redirect_to "/manco/departure?id=#{params[:addr][:id]}&supplier_id=98&way=#{@way} " }
     end
   else
     render 'error.js' #, status: :unprocessable_entity
   end
 end

   def departure_new
     way=params[:way]
     if way =="departure"
       @manco_title="新增装货地址"
     elsif  way =="arrival"
       @manco_title="新增卸货地址"

     end
     supplier_id = params[:supplier_id]
     @supplier =Ecstore::Supplier.find(supplier_id)
     @addr=Ecstore::MemberAddr.new
     @action_url="creat_addr"
     @method="post"

   end

   def creat_addr
     @way=params[:way]
     @addr = Ecstore::MemberAddr.new params[:addr].merge!(:member_id=>@user.member_id)
     @addr = Ecstore::MemberAddr.new(params[:addr])
     if @addr.save
       respond_to do |format|
         format.js
         format.html { redirect_to "/manco/departure?id=#{params[:addr][:id]}&supplier_id=98&way=#{@way}" }
       end
     else
       render 'error.js' #, status: :unprocessable_entity
     end
   end

   def cart_goods ###万家预充值
         @manco_title="预付充值"
       @supplier=Ecstore::Supplier.find(params[:supplier_id])
       @cart_name=Ecstore::Good.where(:cat_id=>"600")###万家物流充值卡cat_id＝588
        good_name= params[:cart_name]
       if good_name
         @good=Ecstore::Good.find_by_name(good_name)

       end


      render layout: @supplier.layout
   end

def cart_goodes

      good_name= params[:cart_name]

    @good=Ecstore::Good.find_by_name(good_name)


end

 def advance
   @manco_title="我的预付充值"
   @supplier=Ecstore::Supplier.find(params[:supplier_id])
   @user=Ecstore::User.find(params[:user_id])
   @advances = @user.member_advances.paginate(:page=>params[:page],:per_page=>10)
   render layout: @supplier.layout
end


  def follow
    @manco_title="运单查询"###快递跟踪
    if @user
      @title=["  ","操作时间","操作网点","环节:","操作人:","单证号:","司机:","车牌号:","联系电话:","件数:","体积(m3):","重量:","备注:"]
      @supplier_id=params[:supplier_id]
      @supplier = Ecstore::Supplier.find(@supplier_id)
      @orderBarcode= params[:orderBarcode]
      @count=0
      url = URI.parse('http://101.226.243.46:8090/getOrder_Ysls')

      Net::HTTP.start(url.host, url.port) do |http|
        req = Net::HTTP::Post.new(url.path)
        req.set_form_data({ 'companyId' => '20837', 'orderBarcode' => @orderBarcode })

        @h_table= Nokogiri::HTML(http.request(req).body.force_encoding("UTF-8")).css("div")

      end
    else
      return_url={:return_url => "/manco/follow?supplier_id=#{@supplier_id}"}.to_query
      redirect_to "/auto_login?#{return_url}&id=#{@supplier_id}"
    end
  end

end





