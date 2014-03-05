#encoding:utf-8
class Patch::MembersController < ApplicationController
	
	before_filter :authorize_user!
	# layout 'standard'
	layout "patch"

	before_filter do
		clear_breadcrumbs
		add_breadcrumb("我的贸威",:member_path)
	end


	def show
		@orders = @user.orders.limit(5)
		@unpay_count = @user.orders.where(:pay_status=>'0',:status=>'active').size
		add_breadcrumb("我的贸威")
	end

	def orders
		@orders = @user.orders.paginate(:page=>params[:page],:per_page=>10)
		add_breadcrumb("我的订单")
	end

	def coupons
		@user_coupons = @user.user_coupons.paginate(:page=>params[:page],:per_page=>10)
		add_breadcrumb("我的优惠券")
  end

  def goods
    @orders = @user.orders.paginate(:page=>params[:page],:per_page=>10)
    add_breadcrumb("我的商品")
  end

	def advance
		@advances = @user.member_advances.paginate(:page=>params[:page],:per_page=>10)
		add_breadcrumb("我的预存款")
	end
	
	def favorites
		@favorites = @user.favorites.includes(:good).paginate(:page=>params[:page],:per_page=>10,:order=>"create_time desc")
		add_breadcrumb("我的收藏")
	end
	
end
