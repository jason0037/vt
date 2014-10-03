#encoding:utf-8
class Patch::MemberAddrsController < ApplicationController
  # layout 'standard'
  layout "patch"

  before_filter do
    clear_breadcrumbs
    add_breadcrumb("我的贸威",:member_path)
  end

  def new
    @addr = Ecstore::MemberAddr.new
    if params[:platform]=="mobile"
      @supplier = Ecstore::Supplier.find(@user.account.supplier_id)
      layout = @supplier.layout
      render :layout =>layout
    end
  end

  def index
    @addrs = @user.member_addrs.paginate(:per_page=>10,:page=>params[:page])
    add_breadcrumb("收货地址")

    if params[:platform]=="mobile"
      @supplier = Ecstore::Supplier.find(@user.account.supplier_id)
      layout =@supplier.layout
      render :layout =>layout
      @newurl = "new_memberaddr_add?supplier_id=#{@supplier.id}"
    else
      @newurl = "new"
    end
  end

  def edit
    @addr = Ecstore::MemberAddr.find(params[:id])
    @method = :put
    @action_url = member_addr_path(@addr)
=begin
    respond_to do |format|
      format.html
      format.js
    end
=end
    if params[:platform]=="mobile"
      @supplier = Ecstore::Supplier.find(@user.account.supplier_id)
      layout = @supplier.layout
      render :layout =>layout
    end
  end

  def create
    @addr = Ecstore::MemberAddr.new params[:addr].merge!(:member_id=>@user.member_id)

    return_url= params[:return_url]

    @addr.save

    if return_url
      @ids=@addr.addr_id
      session[:depar]=@ids
      redirect_to return_url
    else
         respond_to do |format|
           format.js
           format.html { redirect_to "/member_addrs?platform=#{params[:platform]}" }
         end
    end


  end
  def new_memberaddr_add
    @supplier=Ecstore::Supplier.find_by_id(params[:supplier_id])
    @addr=Ecstore::MemberAddr.new
    render :layout=>@supplier.layout
  end

  def update
    @addr = Ecstore::MemberAddr.find(params[:id])
    if @addr.update_attributes(params[:addr])
      respond_to do |format|
        format.js
        format.html { redirect_to "/member_addrs?platform=#{params[:platform]}" }
      end
    else
      render 'error.js' #, status: :unprocessable_entity
    end
  end

  def destroy
    @addr = Ecstore::MemberAddr.find(params[:id])
    @addr.destroy
    redirect_to "/member_addrs?platform=#{params[:platform]}"
  end


  def _form_manco_second
    session[:depars]=params[:member_departure_id]  ##有寄货地址 没收货地址的
    @addr = Ecstore::MemberAddr.new



    render :layout => "manco_new"
  end
  def addship


    @addr = Ecstore::MemberAddr.new params[:addr].merge!(:member_id=>@user.member_id)
    if @addr.save
      @arrid=@addr.addr_id

      session[:arri]=@arrid
      redirect_to '/orders/ordersnew_manco'
    end
  else "/member_addrs/_form_manco_second"
  end
    end

