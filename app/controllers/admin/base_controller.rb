#encoding:utf-8
class Admin::BaseController < ActionController::Base
	include Admin::SessionsHelper

	protect_from_forgery

	layout 'admin'
	require "pp"

	

#	before_filter :authorize_admin!
#	before_filter :require_permission!,:except=>[:select_goods,:select_gifts,:select_coupons,:search]

	def authorize_admin!
		redirect_to new_admin_session_path unless current_admin
	end

	def require_permission!
		return true if controller_name == "sessions"
		unless current_admin.has_right_of(controller_name,action_name)
			if request.xhr?
				render :js=>"alert('您没有权限操作！')"
			else
				render :text=>"您没有权限操作！",:layout=>"admin"
			end
		end
		
	end


	def water_logger
		Logger.new("log/watermark.log")
	end

	def coupon_logger
		@logger ||= Logger.new("log/coupon.log")
	end

end


