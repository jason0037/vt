#encoding:utf-8
class SessionsController < ApplicationController
  require 'rest-client'

  skip_before_filter :authorize_user!
  layout 'login'

  def new

  end

  def auto_login1
    supplier_id = params[:id]
    if params[:supplier_id]
      supplier_id  = params[:supplier_id]
    end
    @supplier = Ecstore::Supplier.find(supplier_id)

    #redirect_uri = "http://vshop.trade-v.com/auth/weixin/callback?supplier_id=#{@supplier.id}"
    #redirect_uri= URI::escape(redirect_uri)
    redirect_uri="http%3a%2f%2fvshop.trade-v.com%2fauth%2fweixin%2f#{supplier_id}%2fcallback"
    #redirect_uri="http%3a%2f%2fvshop.trade-v.com%2fautologin1"

    #@oauth2_url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{@supplier.weixin_appid}&redirect_uri=#{redirect_uri}&response_type=code&scope=snsapi_base&state=STATE#wechat_redirect"
    @oauth2_url = "https://open.weixin.qq.com/connect/qrconnect?appid=#{@supplier.weixin_appid}&redirect_uri=#{redirect_uri}&response_type=code&scope=snsapi_login&state=STATE#wechat_redirect"
    # res_data = RestClient.get 'https://open.weixin.qq.com/connect/oauth2/authorize',
    #   {:params => {:appid => @supplier.weixin_appid, :redirect_uri=>redirect_uri, :response_type=>'code',:scope=>'snsapi_base',:state=>'STATE#wechat_redirect'}}
    # # RestClient.get(self.action)
    # # res_data = RestClient.get self.action , xml , {:content_type => :xml}
    # res_data_xml = res_data.force_encoding('gb2312').encode

   # res_data_hash = Hash.from_xml(res_data_xml)
    # @article = Imodec::Page.new do |al|
    #   al.body = res_data_xml
    # end
    # @article.save!
# return render :text=>res_data_xml#.gsub('<','||')  #res_data.code
    return_url  = params[:return_url]
    session[:return_url] =  return_url
    redirect_to  @oauth2_url

  end

  def auto_login
    supplier_id = params[:id]
    if params[:supplier_id]
      supplier_id  = params[:supplier_id]
    end
    if supplier_id.empty?
      supplier_id =78
    end
    @supplier = Ecstore::Supplier.find(supplier_id)

    #redirect_uri = "http://vshop.trade-v.com/auth/weixin/callback?supplier_id=#{@supplier.id}"
    #redirect_uri= URI::escape(redirect_uri)
    redirect_uri="http%3a%2f%2fvshop.trade-v.com%2fauth%2fweixin%2f#{supplier_id}%2fcallback"

   # @oauth2_url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{@supplier.weixin_appid}&redirect_uri=#{redirect_uri}&response_type=code&scope=snsapi_base&state=STATE#wechat_redirect"
     @oauth2_url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{@supplier.weixin_appid}&redirect_uri=#{redirect_uri}&response_type=code&scope=snsapi_userinfo&state=STATE#wechat_redirect"

    return_url  = params[:return_url]
    session[:return_url] =  return_url
    redirect_to  @oauth2_url

  end

  def new_mobile
    @no_need_login = 1
    supplier_id = params[:id]
    if params[:supplier_id]
      supplier_id  = params[:supplier_id]
    end
    if supplier_id.nil?
      supplier_id =78
    end
    @supplier = Ecstore::Supplier.find(supplier_id)

    #redirect_uri = "http://vshop.trade-v.com/auth/weixin/callback?supplier_id=#{@supplier.id}"
    #redirect_uri= URI::escape(redirect_uri)
    redirect_uri="http%3a%2f%2fvshop.trade-v.com%2fauth%2fweixin%2f#{supplier_id}%2fcallback"

    @oauth2_url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{@supplier.weixin_appid}&redirect_uri=#{redirect_uri}&response_type=code&scope=snsapi_base&state=STATE#wechat_redirect"
     return_url  =params[:return_url]

    session[:return_url] =  return_url

    # return redirect_to(after_user_sign_in_path) if signed_in?
     @no_need_login = 1
    render :layout=>@supplier.layout
  end



  def register_mobile
    @no_need_login = 1
     supplier_id = params[:id]
    if params[:supplier_id]
      supplier_id  = params[:supplier_id]
    end
    if supplier_id.empty?
      supplier_id =78
    end
    @supplier = Ecstore::Supplier.find(supplier_id)
    
    render :layout => @supplier.layout
    # return redirect_to(after_user_sign_in_path) if signed_in?

  end


  def create

     if params[:supplier_id]
       @supplier_id= params[:supplier_id]

     else
       @supplier_id = params[:id]
     end

     if @supplier_id.nil?
        @supplier_id = 78
     end

      if @supplier_id =="78"
         @return_url=params[:return_url].to_s+"&id=78"
      else
        @return_url=params[:return_url]
      end

    @platform = params[:platform]



    if @platform =='mobile' && @supplier_id.length>0
  	  @account = Ecstore::Account.user_authenticate_mobile(params[:session][:username],params[:session][:password],@supplier_id)
      
    elsif @platform == 'vshop'
      @account = Ecstore::Account.admin_authenticate(params[:session][:username],params[:session][:password])
    else
      @account = Ecstore::Account.user_authenticate(params[:session][:username],params[:session][:password])
    end
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
      supplier_id=

      if params[:platform]=="mobile"

                 return_url=params[:return_url].to_s+"&id=#{supplier_id}"

         redirect_to "/mlogin?id=#{params[:id]}&supplier_id=#{params[:id]}&return_url=#{return_url}"


      elsif params[:platform]=="vshop"
           redirect_to "/vshop"
      else

        redirect_to "/"
      end

  end


end
