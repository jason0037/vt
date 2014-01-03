#encoding:utf-8
class ResetPasswordMailer < ActionMailer::Base
  default from: "TRADE-V<cs@iotps.com>"


  def reset_password_email(user)
  	@user = user
  	site  = "http://www.trade-v.com"
  	@reset_password_url = "#{site}/users/reset_password?u=#{@user.member_id}&token=#{@user.reset_password_token}"
  	mail(:to => user.email, :subject => "忘记密码")
  end

end
