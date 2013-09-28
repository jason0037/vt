#encoding:utf-8
class UserMailer < ActionMailer::Base
  async = true
  
  default from: "IMODEC<cs@i-modec.com>"


  def user_email(addr,subject)
  	mail(:to => addr, :subject => subject)
  end

end
