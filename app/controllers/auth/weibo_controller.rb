require 'digest/md5'
require 'hashie'
require 'pp'
class Auth::WeiboController < ApplicationController
	skip_before_filter :authorize_user!

	def index 
		auth_ext = Ecstore::AuthExt.find_by_id(cookies.signed[:_auth_ext].to_i) if cookies.signed[:_auth_ext]
		session[:from] = "external_auth"
		
		if auth_ext&&!auth_ext.expired?&&auth_ext.provider == 'weibo'
			if auth_ext.account.nil?
				cookies.delete :_auth_ext
				redirect_to  Weibo.authorize_url
			else
				sign_in(auth_ext.account)
				redirect_to after_user_sign_in_path
			end
		else
			redirect_to Weibo.authorize_url
		end
	end

	def callback
		return redirect_to(site_path) if params[:error].present?

		token = Weibo.request_token(params[:code])
		

		auth_ext = Ecstore::AuthExt.where(:provider=>"weibo",
									:uid=>token.uid).first_or_initialize(
									:access_token=>token.access_token,
									:expires_at=>token.expires_at,
									:expires_in=>token.expires_in)

		if auth_ext.new_record? || auth_ext.account.nil? || auth_ext.account.user.nil?
			client = Weibo.new(:access_token=>token.access_token,:expires_at=>token.expires_at)
			auth_user = client.get('users/show.json',:uid=>token.uid)

			logger.info auth_user.inspect

			login_name = auth_user.screen_name
			check_user = Ecstore::Account.find_by_login_name(login_name)
			
			login_name = "#{login_name}_#{rand(9999)}" if check_user

			now = Time.now
			@account = Ecstore::Account.new  do |ac|
				#account
				ac.login_name = login_name
				ac.login_password = '123456'
		  		ac.account_type ="member"
		  		ac.createtime = now.to_i
		  		# auth_ext
		  		ac.auth_ext = auth_ext
	  		end
	  		Ecstore::Account.transaction do
  				if @account.save!(:validate => false)
		  			@user = Ecstore::User.new do |u|
			  			u.member_id = @account.account_id
			  			u.email = "weibo_user#{rand(9999)}@anonymous.com"
			  			u.sex = case auth_user.gender when 'f'; '0'; when 'm'; '1'; else '2'; end if auth_user
			  			u.member_lv_id = 1
			  			u.cur = "CNY"
			  			u.reg_ip = request.remote_ip
			  			u.addr = auth_user.location || auth_user.loc_name if auth_user
			  			u.regtime = now.to_i
			  		end
		  			@user.save!(:validate=>false)

		  			sign_in(@account)
		  			redirect_to after_user_sign_in_path
		  		end
	  		end
		else
			sign_in(auth_ext.account)
			redirect_to after_user_sign_in_path
		end
	rescue
		redirect_to(site_path)
	end

	def cancel
	end
end