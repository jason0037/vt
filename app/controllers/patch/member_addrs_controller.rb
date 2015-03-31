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
    if @user.nil?
      return render :text=>'请先登录;'
    end
    @addrs = @user.member_addrs.paginate(:per_page=>10,:page=>params[:page])
    add_breadcrumb("收货地址")

    if params[:platform]=="mobile"
      @supplier = Ecstore::Supplier.find(@user.account.supplier_id)

     redirect_to "/member_addrs/mobile?supplier_id=#{@supplier.id}"

    else
      @newurl = "new"

    end

  end
def mobile
  @supplier = Ecstore::Supplier.find(params[:supplier_id])
  @addrs = @user.member_addrs.paginate(:per_page=>10,:page=>params[:page])
  @newurl = "new_memberaddr_add?supplier_id=#{@supplier.id}"

  render :layout => @supplier.layout

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
    elsif params[:platform]=='mobile'
      redirect_to "/member_addrs?platform=#{pramas[:platform]}"

    end
=begin
  respond_to do |format|
           format.js
           format.html { redirect_to "/member_addrs?platform=#{params[:platform]}" }
         end
=end

  end
  def new_memberaddr_add
    supplier_id = params[:supplier_id]
    if supplier_id.nil?
      supplier_id =78
    end
    @supplier=Ecstore::Supplier.find_by_id(supplier_id)
    @addr=Ecstore::MemberAddr.new
    @return_url= params[:return_url]
    if @return_url.nil?
      @return_url="/member_addrs?platform=mobile"
    end
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
    if params[:platform]=="mobile"
      @supplier=Ecstore::Supplier.find(params[:supplier_id])
      redirect_to "/member_addrs/mobile?platform=mobile&supplier_id=#{@supplier.id}"
   else

    redirect_to "/member_addrs?platform=#{params[:platform]}"
  end

  end
  def _form_manco_second
    @manco_title="新增卸货地址"
    session[:depars]=params[:member_departure_id]  ##有寄货地址 没收货地址的
    @addr = Ecstore::MemberAddr.new
    @supplier=Ecstore::Supplier.find(params[:supplier_id])


    render :layout => @supplier.layout
  end
  def addship
   @platform=params[:platform]
   return_url=params[:return_url]
    @supplier=Ecstore::Supplier.find(params[:supplier_id])
    @addr = Ecstore::MemberAddr.new params[:addr].merge!(:member_id=>@user.member_id)

    if @addr.save
      @arrid=@addr.addr_id

      session[:arri]=@arrid
      if return_url
        redirect_to return_url

      else  redirect_to "/orders/new_manco?supplier_id=#{@supplier.id}&platform=#{@platform}"
     end
    else redirect_to "/member_addrs/_form_manco_second?supplier_id=#{@supplier.id}&platform=#{@platform}"

   end
    end

end