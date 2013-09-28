class Admin::UserCouponsController < Admin::BaseController
	def index
		@users  =  Ecstore::User

		order = "regtime desc"
		if params[:order].present?
			field,sorter = params[:order].split("-")
			order = "#{field} #{sorter}"
			@field = field
			@next_order = "#{field}-" + (sorter == "asc" ? "desc" : "asc")
		end

		if params[:s] && params[:s][:q].present?
			q = params[:s][:q]
			@users = @users.joins(:account).where("login_name like ?","%#{q}%")
		end

		if field == 'login_name'
			@users = @users.joins(:account).order(order)
		else
			@users  =  @users.order(order)
		end

		@users  =  @users.paginate(:page=>params[:page],:per_page=>15)

		@coupons = Ecstore::NewCoupon.all
	end

	def create
		@coupon =  Ecstore::NewCoupon.find(params[:coupon_id])
		if @coupon
			@user_coupon = Ecstore::UserCoupon.new(:coupon_id=>params[:coupon_id],
									                                  :member_id=>params[:member_id],
									                                  :coupon_code=>@coupon.generate_coupon_code(true))
			@user_coupon.save
		end

		respond_to do |format|
			format.html
			format.js
		end
	end

	def destroy
		@user_coupon = Ecstore::UserCoupon.find(params[:id])
		# @coupon_code = @user_coupon.coupon_code
		@user_coupon.destroy

		pp @user_coupon
		respond_to do |format|
			format.html { respond_to  admin_user_coupons_url }
			format.js
		end
	end
end
