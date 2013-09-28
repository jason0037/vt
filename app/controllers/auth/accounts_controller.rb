class Auth::AccountsController < ApplicationController
  skip_before_filter :authorize_user!

  def new
       return redirect_to(after_user_sign_in_path)  if signed_in? 
  	@account =  Ecstore::Account.new
      # render "auth/accounts/new", :locals=>{ :provider=>"weibo" }
  end

  def create
  	auth_user = session[:_auth_user]
  	auth_ext = session[:_auth_ext]

  	now = Time.now
  	@account = Ecstore::Account.new(params[:ecstore_account]) do |ac|
  		ac.account_type ="member"
  		ac.createtime = now.to_i
  		ac.auth_ext = auth_ext
  		ac.user.name = auth_user.name if auth_user
  		ac.user.sex = case auth_user.gender when 'f'; '0'; when 'm'; '1'; else '2'; end if auth_user
  		ac.user.member_lv_id = 1
  		ac.user.cur = "CNY"
  		ac.user.reg_ip = request.remote_ip
  		ac.user.addr = auth_user.location || auth_user.loc_name if auth_user
  		ac.user.regtime = now.to_i
  	end

  	if @account.save
  		session.delete :_auth_ext
  		session.delete :_auth_user

            sign_in(auth_ext.account)
            redirect_to after_user_sign_in_path
  	else
  		render "auth/accounts/new", :locals=>{ :provider=>auth_ext.provider }
  	end
  	
  end

end
