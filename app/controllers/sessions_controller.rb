class SessionsController < ApplicationController
  skip_before_filter :authorize_user!
  layout 'login'

  def new

  end

  def new_mobile
    supplier_id =params[:id]
    @supplier = Ecstore::Supplier.find(supplier_id)

    #redirect_uri = "http://www.trade-v.com/auth/weixin/callback?supplier_id=#{@supplier.id}"
    #redirect_uri= URI::escape(redirect_uri)
    redirect_uri="http%3a%2f%2fwww.trade-v.com%2fauth%2fweixin%2fcallback%3fsupplier_id%3d#{@supplier.id}"

    @oauth2_url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{@supplier.weixin_appid}&redirect_uri=#{redirect_uri}&response_type=code&scope=snsapi_base&state=STATE#wechat_redirect"
    session[:return_url] = params[:return_url]
    render :layout => @supplier.layout
    # return redirect_to(after_user_sign_in_path) if signed_in?
  end

  def new_tairyo
    session[:return_url]=params[:return_url]
    render :layout=>"tairyo_new"
    # 大渔饭店
  end

  def new_manco
    session[:return_url]=params[:return_url]
    render :layout=>"manco_new"
  end

  def register_tairyo
    render :layout=>"tairyo_new"
    # 大渔饭店
  end
  def register_manco
    render :layout=>"manco_new"
    # 大渔饭店
  end
  def register_mobile
    supplier_id =params[:id]
    @supplier = Ecstore::Supplier.find(supplier_id)
    render :layout => @supplier.layout
    # return redirect_to(after_user_sign_in_path) if signed_in?
  end
  def create_tairyo
    @return_url = params[:return_url]
    @platform = params[:platform]
    @account = Ecstore::Account.tairyo_authenticate(params[:session][:username],params[:session][:password])

    if @account
      sign_in(@account,params[:remember_me])


      render "create_tairyo"


    else
      render "error"
     end
  end

  def create_manco
    @return_url = params[:return_url]
    @platform = params[:platform]
    @account = Ecstore::Account.manco_authenticate(params[:session][:username],params[:session][:password])

    if @account
      sign_in(@account,params[:remember_me])


      render "create_manco"


    else
      render "error"
    end
  end

  def create
    @supplier_id =params[:id]
  	@return_url = params[:return_url]
    @platform = params[:platform]
  	@account = Ecstore::Account.user_authenticate(params[:session][:username],params[:session][:password])
      
      if @account
  		sign_in(@account,params[:remember_me])
             #update cart
             # @line_items.update_all(:member_id=>@account.account_id,
             #                                       :member_ident=>Digest::MD5.hexdigest(@account.account_id.to_s))

  		render "create"
  	else

  		render "error"
      #  render js: '$("#login_msg").text("帐号或密码错误!").addClass("error").fadeOut(300).fadeIn(300);'
  	end
  end

  def destroy
      sign_out
      # refer_url = request.env["HTTP_REFERER"]
      # refer_url = "/" unless refer_url
      if params[:platform]=="mobile"
        redirect_to "/m"
      elsif
        redirect_to "/vshop"
      else

        redirect_to "/"
      end

  end

  def destroy_tairyo
    sign_out
    # refer_url = request.env["HTTP_REFERER"]
    # refer_url = "/" unless refer_url
    if params[:platform]=="tairyo"
      redirect_to "/tairyo"
    elsif
    redirect_to "/vshop"
    else

      redirect_to "/"
    end

  end

  def destroy_manco
    sign_out
    # refer_url = request.env["HTTP_REFERER"]
    # refer_url = "/" unless refer_url
    if params[:platform]=="manco"
      redirect_to "/manco"
    elsif
    redirect_to "/vshop"
    else

      redirect_to "/"
    end

  end
end
