class SessionsController < ApplicationController
  skip_before_filter :authorize_user!
  layout 'login'

  def new
  	# return redirect_to(after_user_sign_in_path) if signed_in?
  end

  def new_mobile
    render :layout=>"mobile_new"
    # return redirect_to(after_user_sign_in_path) if signed_in?
  end

  def register_mobile
    render :layout=>"mobile_new"
    # return redirect_to(after_user_sign_in_path) if signed_in?
  end

  def create
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

end
