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
          unless params[:return_url].nil?
            redirect_to params[:return_url]
          else
            if params[:platform]=="vshop"
              redirect_to "/vshop/login" ,:notice=>"不是供应商"
            else
  		   redirect_to after_admin_sign_in_path
              end
          end
      else
        if params[:platform]=="vshop"
          redirect_to "/vshop/login" ,:notice=>"用户名或密码错误"
        else
          redirect_to new_admin_session_path,:notice=>"用户名或密码错误"
        end

  	end
  end
  	
  def destroy
  	admin_sign_out
    if params[:platform]=="vshop"
      redirect_to "/vshop/login"
   else

  	redirect_to new_admin_session_path
  end
  end
end
