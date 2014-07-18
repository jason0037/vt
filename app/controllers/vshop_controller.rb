#encoding:utf-8
class VshopController < ApplicationController

  layout "vshop"

  def new
  	@account = Ecstore::Account.new
  end

  def login

  end

  def register

  end

  def create_session
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

  def destroy_session
    sign_out
    # refer_url = request.env["HTTP_REFERER"]
    # refer_url = "/" unless refer_url
    if params[:platform]=="mobile"
      redirect_to "/m"
    else
      redirect_to "/"
    end

  end

  def create
  	now  = Time.now
	  @account = Ecstore::Account.new(params[:user]) do |ac|
  		ac.account_type ="member"
  		ac.createtime = now.to_i
  		ac.user.member_lv_id = 1
  		ac.user.cur = "CNY"
  		ac.user.reg_ip = request.remote_ip
  		ac.user.regtime = now.to_i
  	end

	  if @account.save
      sign_in(@account)
      @return_url=params[:return_url]
      render "create"
    else
      render "error"
    end
  end

  def search
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
            render "find_by_#{@by}"
          else
            redirect_to forgot_password_users_url(:by=>@by), :notice=> "您输入的#{col}不存在"
          end
      else
          redirect_to forgot_password_users_url(:by=>@by), :notice=> "请输入#{col}"
      end
  end

  def forgot_password
    @title = "找回密码"
    render :layout=>"simple"
  end

  def send_reset_password_instruction
    @title = "找回密码"
    member_id = params[:user][:member_id]
    @by = params[:user][:by]
    @user = Ecstore::User.where(:member_id=>member_id).first
    @user.send_reset_password_instruction(@by)

    respond_to do |format|
      format.js { render :nothing=>true }
      format.html
    end

  end

  def reset_password
    @title = "重设密码"
    by = params[:by] || "email"
    
    @user = Ecstore::User.where(:member_id=>params[:u],:reset_password_token=>params[:token]).first

    respond_to do |format|
      if @user && !@user.reset_password_token_expired?
        format.js { render :js=>"window.location.href='#{reset_password_users_url(params)}'" }
        format.html
      else
        format.js { render "sms_code_error" }
        format.html { redirect_to forgot_password_users_url, :notice=>"重设密码的链接错误" }
      end
    end

  end

  def change_password
    @title = "修改密码成功"
    @account = Ecstore::Account.where(:account_id=>params[:account][:account_id]).first
    if @account.change_password(params[:account][:login_password],
                                                           params[:account][:login_password_confirmation])
      @account.user.clear_reset_password_token
    else
      @user = @account.user
      render :reset_password
    end
  end

end
