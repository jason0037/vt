#encoding:utf-8
class MancoController < ApplicationController

  layout "manco_template"
  def index

  end
  def show

  end

  def find_manco
     if @user

     else
       redirect_to "/wlogin?return_url=manco/find_manco"
     end
  end

  def user
    if @user

    login_name=@user.login_name
    account_id=Ecstore::Account.find_by_sql(["select account_id from sdb_pam_account where login_name=?",login_name])
    @member=Ecstore::Member.find_by_sql(["select * from sdb_b2c_members where member_id=?",account_id])
   else
       redirect_to '/wlogin?return_url=/manco/user'
   end

  end


  def good_source
    @addr=Ecstore::MemberAddr.new
    account=@user.member_id
    @member= Ecstore::User.find_by_member_id(account)

  end

 def black_good_index     ###货源信息小黑板
   # @member=   Ecstore::User.find_by_member_id(account)
   @good=Ecstore::BlackGood.paginate :page=>params[:page],        ###分页语句
                                :per_page =>5,              ###当前只显示一条
                                :conditions => ["cat_id=571"]    ####小黑板对应的类别为571
  # @good =@good.where("downtime>UNIX_TIMESTAMP(now()) ")
 end

  def blackgood_add
    departure= params[:departure]
    arrival= params[:arrival]
    goodsname=departure+"-"+arrival;
    @blackgood=Ecstore::BlackGood.new(params[:black_good]) do |sv|
       sv.name= goodsname
      sv.uptime=Time.now
       sv.downtime=Time.parse(params[:black_good][:downtime]).to_i

    end.save

    redirect_to "/manco/black_good_index"
  end
  def black_index
  if @user
    # @good=Ecstore::Good.find_all_by_cat_id(571)
    account=@user.member_id
    @member=   Ecstore::User.find_by_member_id(account)
      @good=Ecstore::Good.paginate :page=>params[:page],        ###分页语句
                                   :per_page => 5,              ###当前只显示一条
                                   :conditions => ["cat_id=571"]    ####小黑板对应的类别为571
    @good =@good.where("downtime>UNIX_TIMESTAMP(now()) ")
  else
  redirect_to '/wlogin?return_url=/manco/black_index'
  end
  end

  def blackboardfind_e
    departure= params[:departure]
    arrival= params[:arrival]
    goodsname=departure+"-"+arrival;
    @goods=Ecstore::Good.where(:name=>goodsname,:cat_id=>"570")   ####万家线路图对应的类别为570


  end





  def new
    @good  =  Ecstore::Good.new

    @method = :post
    redirect_to '/manco/blackbord'
  end
  def black_board

  end


  def blackbord
    if @user
       account=@user.member_id
       @member=   Ecstore::User.find_by_member_id(account)
      unless @member.name and @member.bank_info          ####判断逻辑不严谨
        redirect_to '/profile/mancouser'
      end
  else
    redirect_to '/wlogin?return_url=/manco/blackbord'
  end


end

  def blackbord_add
    ###发布小黑板商品

    @good = Ecstore::Good.new(params[:good]) do |ac|
          ac.bn="a098"+Time.now.strftime('%Y%m%d%H%M%S')
          ac.unit= "吨"
          ac.uptime=Time.now
          ac.downtime=Time.parse(params[:good][:downtime]).to_i

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
           if spec_value_id.nil?
                    Ecstore::SpecValue.new do |sv|
                      sv.spec_id=12
                      sv.spec_value =specname
                    end.save
           else


             sp_val_id = Ecstore::SpecValue.where(:spec_value=>specname,:spec_id=>12).first.spec_value_id
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
  end

  def user
    render :layout => "manco_new"
  end

  def show_carblack

      id=params[:id]
    @good =Ecstore::Good.paginate :page=>params[:page],        ###分页语句
                                 :per_page => 5,              ###当前只显示一条
                                 :conditions => ["member_id=#{id}"]

    render :layout => "manco_template"
  end

  end                                 ###分页语句





