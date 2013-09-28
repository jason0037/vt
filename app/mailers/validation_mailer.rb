#encoding:utf-8
class ValidationMailer < ActionMailer::Base
  default from: "IMODEC<cs@i-modec.com>"


  def verify_email(user)
  	@user = user
  	site  = "http://test2.i-modec.com"
  	site  = "http://www.i-modec.com" if Rails.env == "production"
  	@verify_email_url = "#{site}/validation/verify_email?u=#{user.member_id}&token=#{user.email_code}"
  	mail(:to => user.email, :subject => "摩登客验证邮件")
  end


end
