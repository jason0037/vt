#encoding:utf-8
class Admin::SessionsController < Admin::BaseController
  skip_before_filter :authorize_admin!, :except=>[:destroy]

  def new
  	redirect_to after_admin_sign_in_path if admin_signed_in?
  end

  def create
  	name  = params[:session][:login_name]
  	password = params[:session][:login_password]
    
      admin =  Ecstore::Account.admin_authenticate(name,password)
      if admin
            admin_sign_in admin
  		redirect_to after_admin_sign_in_path
  	else
  		redirect_to new_admin_session_path,:notice=>"用户名或密码错误"
  	end
  end
  	
  def destroy
  	admin_sign_out
  	redirect_to new_admin_session_path
  end

end
