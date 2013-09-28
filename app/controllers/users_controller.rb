#encoding:utf-8
class UsersController < ApplicationController
  
  def new
  	@account = Ecstore::Account.new
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
            render "create"
	 else
            
            render "error"
        end
  end

end
