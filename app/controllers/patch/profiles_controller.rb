#encoding:utf-8
class Patch::ProfilesController < ApplicationController
  # skip_before_filter :authorize_user!
  before_filter :find_user

  #layout "patch"
  layout 'left_cheuks'

  before_filter do
    clear_breadcrumbs
    add_breadcrumb("个人中心",:member_path)
  end
  
  def show
    @tab = params[:tab] || "basic"

    add_breadcrumb("个人信息")
  end

  def edit
      @tab = params[:tab] || "basic"

      add_breadcrumb("编辑个人信息")
  end



  def update

      params[:ecstore_user].merge!(:bank_info=>params[:bank_info].to_s) if params[:bank_info]

      params[:ecstore_user].merge!(params[:date]) if params[:date]
      @tab = params[:tab]
      if params[:tab]=="interest"
        params[:ecstore_user].merge!(:places=>nil) unless params[:ecstore_user][:places]
        params[:ecstore_user].merge!(:interests=>nil) unless params[:ecstore_user][:interests]
        params[:ecstore_user].merge!(:colors=>nil) unless params[:ecstore_user][:colors]
      end

      if @user.update_attributes(params[:ecstore_user])
        if params[:supplier]
          redirect_to "/vshop/#{params[:supplier]}"
        else
          redirect_to profile_path(:tab=>params[:tab]), :notice=>"保存成功."
        end
      else
          render "/patch/profiles/edit"
      end
  end

  def password
    add_breadcrumb("修改密码")
  end

  def modify_password
     @account =  current_account
     if @account.update_attributes(params[:account])
        sign_out 
        redirect_to root_path
     else
        render :password
     end
  end

  private
    def  find_user
      # return @user = Ecstore::User.find_by_email("yxf4559@163.com")
      if signed_in?
        @user = current_account.user
      else
        redirect_to login_path
      end
    end
end
