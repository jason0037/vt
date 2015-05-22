#encoding:utf-8
class UsersController < ApplicationController
  skip_before_filter :find_cart!
  skip_before_filter :find_path_seo
  
  layout "simple"

  def new
  	@account = Ecstore::Account.new
  end



  def create
    supplier_id =78

    if params[:supplier_id].length>0
      supplier_id = params[:supplier_id]
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
      if @return_url=='/mlogin'
        @return_url ='tuan'
      end
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
    @by = 'email' #params[:users][:by]
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
