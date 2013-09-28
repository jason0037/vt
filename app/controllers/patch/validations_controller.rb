#encoding:utf-8
require 'sms'
require 'securerandom'
class Patch::ValidationsController < ApplicationController
	layout 'patch'



	before_filter do
		clear_breadcrumbs
		add_breadcrumb("我的摩登客",:member_path)
	end

	def show
		add_breadcrumb("账户安全")
	end

	def email
		add_breadcrumb("邮箱认证")
	end

	def mobile
		add_breadcrumb("手机认证")
	end

	def sent
		
		if params[:validation].key?(:mobile)
			mobile =  params[:validation]&&params[:validation][:mobile]
			return render :js=>"alert('请输入手机号码')" if mobile.blank?
			sms_code = (0..5).collect { rand(10) }.join("")
			text = "手机验证码:#{sms_code},如非本人操作请忽略。[I-Modec摩登客]"
			if Sms.send(mobile,text)
				@user.update_attribute(:mobile, mobile)
				@user.update_attribute(:sms_code, sms_code)
				@user.update_attribute(:sent_sms_at, Time.now)
				@result = true
				@msg = "手机验证码已经发送"
			else
				@result = false
				@msg = "发送手机验证码失败"
			end
			return render "sent_mobile"
		end

		if params[:validation].key?(:email)
			email = params[:validation][:email]
			email_code = SecureRandom.hex
			@user.update_attribute :email, email
			@user.update_attribute :email_code, email_code
			ValidationMailer.verify_email(@user).deliver
			return render :inline=>"<p>验证邮件已发送。</p>", :layout=>"patch"
		end

		render :status=>:not_found
	end

	def verify
		sms_code = params[:validation] && params[:validation][:sms_code]

		if sms_code.to_s == @user.sms_code.to_s && @user.sent_sms_at + 30.minutes > Time.now
			@user.update_attribute(:sms_validate, 'true')
			@user.update_attribute(:sms_code, nil)
			@msg = "手机验证成功"
			@result = true
		else
			@msg = "验证码错误或过期失效，请重新发送。"
			@result = false
		end

		render "verify_mobile"
	end

	def verify_email
		member_id = params[:u]
		token = params[:token]

		 if member_id && token
			user = Ecstore::User.find_by_member_id(member_id)
			if user.email_code == token
				user.update_attribute :email_code, nil
				user.update_attribute :email_validate, 'true'
				render :inline=>"<p>邮箱验证成功</p>", :layout=>"standard"
			else
				render :inline=>"<p>邮箱验证失败</p>", :layout=>"standard"
			end
		else
			redirect_to root_path
		end
	end
end
