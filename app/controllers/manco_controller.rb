#encoding:utf-8
require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'open-uri'
class MancoController < ApplicationController

  layout "manco"
  def index

  end
  def map
    supplier_id=params[:supplier_id]
    @supplier = Ecstore::Supplier.find(supplier_id)
  end
  def show
    supplier_id=params[:supplier_id]
    @supplier = Ecstore::Supplier.find(supplier_id)
  end

  def find_manco
    @line_items.delete_all
    supplier_id = params[:supplier_id]

  @supplier =Ecstore::Supplier.find(supplier_id)


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
    supplier_id = params[:supplier_id]
    @supplier =Ecstore::Supplier.find(supplier_id)
    @addr=Ecstore::MemberAddr.new
    account=@user.member_id
    @member= Ecstore::User.find_by_member_id(account)

  end

 def black_good_index
   @line_items.delete_all     ###货源信息小黑板
   supplier_id = params[:supplier_id]


     @supplier =Ecstore::Supplier.find(supplier_id)
      @good=Ecstore::BlackGood.paginate :page=>params[:page],        ###分页语句
                                :per_page =>5,              ###当前只显示一条
                                :conditions => ["cat_id=571"]    ####小黑板对应的类别为571
      @good =@good.where("downtime>UNIX_TIMESTAMP(now()) ")

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
    @line_items.delete_all
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
    departure= params[:departure]
    arrival= params[:arrival]
    goodsname=departure+"-"+arrival;
    @goods=Ecstore::Good.where(:name=>goodsname,:cat_id=>"570").first   ####万家线路图对应的类别为570


  end

  def main
    supplier_id=params[:supplier_id]
    @supplier = Ecstore::Supplier.find(supplier_id)
  end

  def history
    supplier_id=params[:supplier_id]
    @supplier = Ecstore::Supplier.find(supplier_id)
  end

 def express
   @line_items.delete_all ###落地配服务
  supplier_id=params[:supplier_id]
   @supplier = Ecstore::Supplier.find(supplier_id)

  end

  def follow       ###快递跟踪
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
  end
  def new
    @good  =  Ecstore::Good.new

    @method = :post
    redirect_to '/manco/blackbord?supplier_id=98'
  end
  def black_board

  end


  def blackbord
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
    ###发布小黑板商品
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

  def manco_comment             ###评论
    supplier_id = params[:supplier_id]
    @supplier =Ecstore::Supplier.find(supplier_id)

  end





  def show_carblack
    supplier_id = params[:supplier_id]
    @supplier =Ecstore::Supplier.find(supplier_id)
      id=params[:id]
    @good =Ecstore::Good.paginate :page=>params[:page],        ###分页语句
                                 :per_page => 5,              ###当前只显示一条
                                 :conditions => ["member_id=#{id}"]
     render :layout => @supplier.layout

  end

   def mancoluodipei
     departure= params[:departure]
     arrival= params[:arrival]
     distribution=params[:distribution]
      goods=departure+"-"+arrival;
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
      @def_addrs = @addrs.where(:addr_type=>1) || @addrs.first
   elsif  @way =="arrival"
     @addrs =  @user.member_addrs
     @def_addrs = @addrs.where(:addr_type=>0) || @addrs.first
     end
 end

def departure_edit
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


  end





