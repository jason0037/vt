require 'digest/md5'
require 'hashie'
require 'pp'
class Auth::WeixinController < ApplicationController
	skip_before_filter :authorize_user!

	def index 
		auth_ext = Ecstore::AuthExt.find_by_id(cookies.signed[:_auth_ext].to_i) if cookies.signed[:_auth_ext]
		session[:from] = "external_auth"
		
		if auth_ext&&!auth_ext.expired?&&auth_ext.provider == 'weixin'
			if auth_ext.account.nil?
				cookies.delete :_auth_ext
				redirect_to  Weixin.authorize_url
			else
				sign_in(auth_ext.account)
				redirect_to after_user_sign_in_path
			end
		else
			redirect_to Weixin.authorize_url
		end
	end

	def callback

		return redirect_to(site_path) if params[:error].present?
	    supplier_id = params[:id]
	    if params[:supplier_id]
	        supplier_id=params[:supplier_id]
	    end

	    if supplier_id.nil?
	    	supplier_id = 78
	    end

	    return_url= session[:return_url]
	    session[:return_url]=''

	    @supplier =Ecstore::Supplier.find(supplier_id)
	    appid = @supplier.weixin_appid
	    secret = @supplier.weixin_appsecret
		# return render :text=>params[:code]
		#token = Weixin.request_token(params[:code])
	    token = Weixin.request_token_multi(params[:code],appid,secret)
	    user_info = Weixin.get_userinfo_multi(token.openid,token.access_token)
	  	# return  render :text=>user_info.nickname

		auth_ext = Ecstore::AuthExt.where(:provider=>"weixin",
						:uid=>token.openid).first_or_initialize(
						:access_token=>token.access_token,
		   #            :refresh_token=>token.refresh_token,
						:expires_at=>token.expires_at,
						:expires_in=>token.expires_in)

		if auth_ext.new_record? || auth_ext.account.nil? || auth_ext.account.user.nil?
			client = Weixin.new(:access_token=>token.access_token,:expires_at=>token.expires_at)
			auth_user = client.get('users/show.json',:uid=>token.uid)

			logger.info auth_user.inspect

			#login_name = auth_user.screen_name
	        login_name = token.openid
	    	#  return render :text=>login_name
			check_user = Ecstore::Account.find_by_login_name(login_name)
			
			login_name = "#{login_name}_#{rand(9999)}" if check_user

			now = Time.now

			@account = Ecstore::Account.new  do |ac|
				#account
				ac.login_name = login_name
				ac.login_password = '123456'
		  		ac.account_type ="member"
		  		ac.createtime = now.to_i
		  		ac.auth_ext = auth_ext
        		ac.supplier_id = supplier_id
	  		end

	  		Ecstore::Account.transaction do
  				if @account.save!(:validate => false)
		  			@user = Ecstore::User.new do |u|
			  			u.member_id = @account.account_id
			  			u.email = "weixin_user#{rand(9999)}@anonymous.com"
			  			u.source = "weixin"
			  			#u.sex = case auth_user.gender when 'f'; '0'; when 'm'; '1'; else '2'; end if auth_user
			  			u.sex = user_info.sex
			  			u.member_lv_id = 1
			  			u.cur = "CNY"
			  			u.reg_ip = request.remote_ip
			  			#u.addr = auth_user.location || auth_user.loc_name if auth_user
			  			u.addr = user_info.country+':'+user_info.province+'/'+user_info.city
			  			u.name = user_info.nickname
			  			u.weixin_nickname = user_info.nickname
			  			u.weixin_area = user_info.country+':'+user_info.province+'/'+user_info.city
			  			u.weixin_headimgurl = user_info.headimgurl
			  			u.weixin_privilege = user_info.privilege
			  			u.weixin_unionid = user_info.unionid
			  			u.regtime = now.to_i
			  		end
		  			@user.save!(:validate=>false)

		  			sign_in(@account,'1')
		  		end
	  		end
		else
			@user = Ecstore::User.where(:member_id=>auth_ext.account_id).first
				@user.weixin_nickname = user_info.nickname
	  			@user.sex = user_info.sex
	  			@user.weixin_area = user_info.country+'/'+user_info.province+'/'+user_info.city
	  			@user.weixin_headimgurl = user_info.headimgurl
	  			@user.weixin_privilege = user_info.privilege
	  			@user.weixin_unionid = user_info.unionid
  			@user.save!(:validate=>false)
			sign_in(auth_ext.account,'1')

			@key = session[:key]
			@url = session[:url]
			if @key　#如果是从推荐页面进来的用户
				
				@mlm = Ecstore::Mlm.where(:member_id=>auth_ext.account_id) #判断是否已经有上级
				if @mlm.new_record?
					@mlm = Ecstore::Mlm.new do |m|
						m.member_id = auth_ext.account_id
						m.superior_id = @key
					end
					@mlm.save!
					#调用微信接口通知上级，新增了下线


					json = "{
'touser':'OPENID',
'template_id':'4mjMdY541r_VElWDbLirzUDFOSD7G3122wwFjtKvX1A',
'url':'http://weixin.qq.com/download',
'topcolor':'#FF0000',
'data':{
'User': {
'value':'黄先生',
'color':'#173177'
},
'Date':{
'value':'06月07日 19时24分',
'color':'#173177'
},
'CardNumber':{
'value':'0426',
'color':'#173177'
},
'Type':{
'value':'消费',
'color':'#173177'
},
'Money':{
'value':'人民币260.00元',
'color':'#173177'
},
'DeadTime':{
'value':'06月07日19时24分',
'color':'#173177'
},
'Left':{
'value':'6504.09',
'color':'#173177'
}
}
}"





				end

			end
		   
		end



		if return_url
	        redirect = return_url
	    else
	    	if supplier_id == 78
	    		redirect  = "/tuan"
	    	else
          		redirect = "/vshop/#{supplier_id}"
          	end
        	#  redirect = after_user_sign_in_path
	    end
	    redirect_to redirect
		#rescue
		#	redirect_to(site_path)
	end

	def cancel
	end
end