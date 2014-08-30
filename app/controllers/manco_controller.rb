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

  def express
  end

  def black_index

    # @good=Ecstore::Good.find_all_by_cat_id(576)
      @good=Ecstore::Good.paginate :page=>params[:page],
                                   :per_page => 1,
                                   :conditions => ["cat_id=576"]
  end

  def serach
    departure= params[:departure]
    arrival= params[:arrival]
    @un= Ecstore::Express.serachall(departure,arrival)
   end

  def f

  end
  def new
    @good  =  Ecstore::Good.new

    @method = :post
  end
  def black_board

  end
  def blackbord_add
    @good  =  Ecstore::Good.new(params[:good])


    if @good.save
      specname=@good.name.gsub(/-/,',')
      spec_id = " "
      spec_id = Ecstore::Spec.where(:spec_name=>specname).first.spec_id
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
          sp_val_id = Ecstore::SpecValue.where(:spec_value=>specname,:spec_id=>spec_id).first.spec_value_id
          Ecstore::GoodSpec.new do |gs|
            gs.type_id =  @good.type_id
            gs.spec_id = spec_id
            gs.spec_value_id = sp_val_id
            gs.goods_id = @good.goods_id
            gs.product_id = @product.product_id
          end.save

    else
          render "new"
        end
      end







end
