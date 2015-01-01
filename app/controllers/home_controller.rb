#encoding:utf-8
class HomeController < ApplicationController
  before_filter :find_user
  before_filter :require_top_cats
	# layout 'magazine'
	layout 'standard'

	def index


		@title = "卓展集团--工业成品专家"

		@home = Ecstore::Home.where(:supplier_id=>nil).last
    @promotions = Ecstore::Promotion.where(:promotion_type=>"door").order("priority")
    @progoods=Ecstore::Promotion.where(:promotion_type=>"goods")


	# 	if signed_in?
	# 	   redirect_to params[:return_url] if params[:return_url].present?
	# end

	end

	def blank
		@return_url = params[:return_url]
		render :layout=>nil
	end





	def topmenu
		render :layout=>nil
	end
	
	def subscription_success
		@title = "卓展集团--工业成品专家"
	end

end
