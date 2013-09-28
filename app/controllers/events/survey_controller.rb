#encoding:utf-8
class Events::SurveyController < ApplicationController
	include Wicked::Wizard


	protect_from_forgery
	
	before_filter :authorize_survey!
	# skip_before_filter :authorize_user!

	steps :start, :i_like_coupon, :go_to_salon,:type_your_mobile

	def show
		render_wizard
	end

	def add_mobile
		if @user.update_attributes(:mobile=>params[:survey][:mobile])
			case params[:survey][:gift]
				when "coupon"
					@user.receive_register_gift("100元抵用券")
					@user.receive_new_coupon
				when "salon"
					@user.receive_register_gift("参与VIP沙龙活动")
			end

			render "completed"
			session.delete("from")
		else
			render "error"
		end
	end


	def update
		case step
	 	      when :i_like_coupon
	 	      		@gift = "coupon"
	 	      		
	 	      		@user.receive_register_gift("100元抵用券")
	 	      		@user.receive_new_coupon
	 	      		render "completed"

	 	      		# if @user.mobile.present?
	 	      		# 	@user.receive_register_gift("100元抵用券")
	 	      		# 	@user.receive_coupon
	 	      		# 	render "completed"
	 	      		# else
	 	      		# 	render "show_mobile"
	 	      		# end

			when :go_to_salon
				@gift = "salon"
				if @user.mobile.present?
					@user.receive_register_gift("参与VIP沙龙活动")
					render "completed"
				else
					render "show_mobile"
				end
		end
	end

	private
  		def finish_survey_path
  			# if session[:from] == "external_auth"
			# 	return "/trust-post_login.html"
			# end

			refer_url = cookies[:unlogin_url]
			if refer_url&& refer_url.present?
				cookies.delete(:unlogin_url)
				refer_url
			else
				"http://#{request.server_name}:#{request.server_port}"
			end
  		end

  		def authorize_survey!
  			@finish_survey_path = finish_survey_path
  			# return @user = Ecstore::User.find_by_name("yangxiaofei")
  			@coupon = Ecstore::NewCoupon.where(:coupon_prefix=>"B0001").first
  			return redirect_to(finish_survey_path) if @coupon&&!@coupon.enable?
  			@user  =  current_account.user
  			return redirect_to(finish_survey_path) if @user&&@user.has_received_gift?
  		end
end
