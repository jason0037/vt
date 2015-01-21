#encoding:utf-8
class UsersController < ApplicationController
  skip_before_filter :find_cart!
  skip_before_filter :find_path_seo
  layout "standard"


  def new
    @account = Ecstore::Account.new

  end

  

  
  def create

    if request.post?
      if captcha_valid? params[:captcha]
        #redirect_to :root, :notice => "valid captcha"
      # else
      #   #flash[:alert] = "invalid captcha"
      #   render "error"
      end
    end

    if  params[:supplier_id]
      supplier_id = params[:supplier_id]
    else
      supplier_id=1
    end
    now  = Time.now
     @account = Ecstore::Account.new(params[:user]) do |ac|
      ac.account_type ="member"
      ac.createtime = now.to_i
      ac.user.member_lv_id = 1
      ac.user.cur = "CNY"
      ac.user.reg_ip = request.remote_ip
      ac.user.regtime = now.to_i
      ac.supplier_id = supplier_id
    end

    if @account.save
      sign_in(@account)
      @return_url=params[:return_url]
      if @return_url =="#{site}+/users/forgot_password"
        @return_url="#{site}+/"

      end
      render "create"
    else
      render "error"
    end
  end
  

  def search
    @platform=params[:platform]
      @title = "找回密码"
      @by = params[:user][:by]
      value = params[:user][:value]
      col =  case @by
          when 'mobile' then '手机号码'
          when 'email' then '邮箱'
          when 'login_name' then '用户名'
          else '用户名'
             end

      if value.present?
          @user = Ecstore::User.joins(:account).where("#{@by} = ?",value).first
          if @user
            if @platform=="vshop"
              render "find_by_#{@by}",:layout=>"vshop"
              else
              render "find_by_#{@by}"
            end

          else
            if @platform=="vshop"
              redirect_to forgot_password_users_url(:by=>@by,:platform=>@platform), :notice=> "您输入的#{col}不存在"  , :layout=>"vshop"
             else
            redirect_to forgot_password_users_url(:by=>@by,:platform=>@platform), :notice=> "您输入的#{col}不存在"  , :layout=>"standard"
            end
          end
      else
        if @platform=="vshop"
          redirect_to forgot_password_users_url(:by=>@by,:platform=>@platform), :notice=> "请输入#{col}" , :layout=>"vshop"
        else
          redirect_to forgot_password_users_url(:by=>@by,:platform=>@platform), :notice=> "请输入#{col}"  ,:layout=>"standard"
          end
      end


  end

  def forgot_password
    @title = "找回密码"
    if params[:platform]=="vshop"
      @platform=params[:platform]
      render :layout=>"vshop"
    else

      render :layout=>"standard"
    end
  end



  def send_reset_password_instruction
    @platform=params[:platform]
    @title = "找回密码"
    member_id = params[:user][:member_id]
    @by = params[:user][:by]
    @user = Ecstore::User.where(:member_id=>member_id).first

    if @platform =="vshop"
      @user.send_reset_password_instruction_vshop(@by)
      render :layout=>"vshop"
    else
      @user.send_reset_password_instruction(@by)
      render :layout=>"standard"
      end
    # respond_to do |format|
    #   format.js { render :nothing=>true }
    #   format.html
    # end

  end

  def reset_password
    @platform= params[:platform]
    @title = "重设密码"
    by = params[:by] || "email"

    @user = Ecstore::User.where(:member_id=>params[:u],:reset_password_token=>params[:token]).first

    respond_to do |format|
      if @user && !@user.reset_password_token_expired?
        if @platform =="vshop"
          format.js { render :js=>"window.location.href='#{reset_password_users_url(params)}'",:layout=>"vshop" }
          format.html{ render :layout=>"vshop"}
        else
          format.js { render :js=>"window.location.href='#{reset_password_users_url(params)}'" }
          format.html
        end

      else
        format.js { render "sms_code_error" }
        format.html { redirect_to forgot_password_users_url, :notice=>"重设密码的链接错误" }
      end
    end

  end

  def change_password
    @platform= params[:platform]
    @title = "修改密码成功"
    @account = Ecstore::Account.where(:account_id=>params[:account][:account_id]).first
    params[:account].delete(:account_id)
    if @account.update_attributes(params[:account])
   # if @account.change_password(params[:account][:login_password],params[:account][:login_password_confirmation])
      @account.user.clear_reset_password_token

      if @platform =="vshop"

        redirect_to "/vshop/login" ,:notice=>'修改成功!请重新登陆'

      end

      #redirect_to "http://weishop.cheuks.com/home"
    else
      @user = @account.user
      render :reset_password
    end


  end

end
