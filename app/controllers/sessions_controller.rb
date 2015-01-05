#encoding:utf-8
class SessionsController < ApplicationController
  require 'rest-client'

  skip_before_filter :authorize_user!
  layout 'login'

  def new

  end

  def auto_login
    supplier_id = params[:id]
    if params[:supplier_id]
      supplier_id  = params[:supplier_id]
    end
    if supplier_id.nil?
      supplier_id=1
    end
    @supplier = Ecstore::Supplier.find(supplier_id)

    #redirect_uri = "http://weishop.cheuks.com/auth/weixin/callback?supplier_id=#{@supplier.id}"
    #redirect_uri= URI::escape(redirect_uri)
    redirect_uri="http%3a%2f%2fweishop.cheuks.com%2fauth%2fweixin%2f#{supplier_id}%2fcallback"

    @oauth2_url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{@supplier.weixin_appid}&redirect_uri=#{redirect_uri}&response_type=code&scope=snsapi_base&state=STATE#wechat_redirect"

    return_url  = params[:return_url]
    session[:return_url] =  return_url
    redirect_to  @oauth2_url

  end

  def new_mobile
    supplier_id = params[:id]
    if params[:supplier_id]
      supplier_id  =params[:supplier_id]
    end
    @supplier = Ecstore::Supplier.find(supplier_id)

    #redirect_uri = "http://weishop.cheuks.com/auth/weixin/callback?supplier_id=#{@supplier.id}"
    #redirect_uri= URI::escape(redirect_uri)
    redirect_uri="http%3a%2f%2fweishop.cheuks.com%2fauth%2fweixin%2f#{supplier_id}%2fcallback"

    @oauth2_url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{@supplier.weixin_appid}&redirect_uri=#{redirect_uri}&response_type=code&scope=snsapi_base&state=STATE#wechat_redirect"
     return_url  =params[:return_url]

    session[:return_url] =  return_url

    # return redirect_to(after_user_sign_in_path) if signed_in?
  end



  def register_mobile
    supplier_id =params[:id]
     if params[:supplier_id]
       supplier_id=params[:supplier_id]
     end
    @supplier = Ecstore::Supplier.find(supplier_id)
    render :layout => @supplier.layout
    # return redirect_to(after_user_sign_in_path) if signed_in?
  end




  def create
    @supplier_id =1
     if params[:supplier_id]
       @supplier_id= params[:supplier_id]

     else
       @supplier_id = params[:id]
     end
      
    @return_url=params[:return_url]


    @platform = params[:platform]

    if @platform =='mobile'
  	  @account = Ecstore::Account.user_authenticate_mobile(params[:session][:username],params[:session][:password],@supplier_id)
    elsif @platform == 'vshop'
      @account = Ecstore::Account.admin_authenticate(params[:session][:username],params[:session][:password])
    else
      @account = Ecstore::Account.user_authenticate(params[:session][:username],params[:session][:password])
    end


    if @account
  #   return render js: "$('#login_msg').text('#{@account.login_name}').addClass('error').fadeOut(300).fadeIn(300);"

  		sign_in(@account,params[:remember_me])
      if @return_url
        redirect_to @return_url
      else          
  		    render "create"
      end
  	else

  		render "error"
      #  render js: '$("#login_msg").text("帐号或密码错误!").addClass("error").fadeOut(300).fadeIn(300);'
  	end
   
  end

  def destroy
      sign_out
      # refer_url = request.env["HTTP_REFERER"]
      # refer_url = "/" unless refer_url
      supplier_id=

      if params[:platform]=="mobile"

                 return_url=params[:return_url].to_s+"&id=#{supplier_id}"

         redirect_to "/mlogin?id=#{params[:id]}&supplier_id=#{params[:id]}&return_url=#{return_url}"


      elsif params[:platform]=="vshop"
           redirect_to "/vshop"

     
      elsif params[:return_url]
          redirect_to  params[:return_url]

      else
        redirect_to "/"
      end

  end


end
