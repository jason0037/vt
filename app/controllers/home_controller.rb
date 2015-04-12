#encoding:utf-8
class HomeController < ApplicationController
  before_filter :find_user
	# layout 'magazine'
	layout 'standard'

	def index
		#redirect_to "http://vshop.trade-v.com/vshop/78"
		@title = "trade-V 跨境贸易直通车"
	  	@galleries = Ecstore::Teg.where(:tag_type=>"gallery")	
	  	@i = 1  	
		@home = Ecstore::Home.where(:supplier_id=>nil).last
		if signed_in?
		    redirect_to params[:return_url] if params[:return_url].present?
		end

		supplier_id = 78
		if  @user
	    else
	       redirect_to  "/auto_login?id=#{supplier_id}&platform=mobile&return_url=/mobile/home/"
	       return
	    end

		respond_to do  |format|
	        format.mobile { render :layout=> 'msite'}
	    end
	end

	def blank
		@return_url = params[:return_url]
		render :layout=>nil
	end

	def topmenu
		render :layout=>nil
	end
	
	def subscription_success
		@title = "trade-V 跨境贸易直通车"
	end

end
