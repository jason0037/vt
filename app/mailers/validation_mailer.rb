#encoding:utf-8
class ValidationMailer < ActionMailer::Base
  default from: "Cheuks<cs@iotps.com>"


  def verify_email(user)
  	@user = user
  	 site  = "http://weishop.cheuks.com/"
  	 site  = "http://weishop.cheuks.com/" if Rails.env == "production"

  	@verify_email_url = "#{site}/validation/verify_email?u=#{user.member_id}&token=#{user.email_code}"
  	mail(:to => user.email, :subject => "Cheuks验证邮件")

  end


end
