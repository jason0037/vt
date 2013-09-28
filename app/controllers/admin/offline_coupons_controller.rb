class Admin::OfflineCouponsController < Admin::BaseController
	
	def index
		@coupons = Ecstore::OfflineCoupon.paginate(:per_page=>10,:page=>params[:page],:order=>"created_at asc")
	end

	def new
		@coupon  = Ecstore::OfflineCoupon.new
		@action_url = admin_offline_coupons_path
		@method = :post
	end

	def show
		@coupon  = Ecstore::OfflineCoupon.find(params[:id])
	end

	def edit
		@coupon  = Ecstore::OfflineCoupon.find(params[:id])
		@action_url = admin_offline_coupon_path(@coupon)
		@method = :put
	end

	def create
		@coupon  = Ecstore::OfflineCoupon.new(params[:coupon])

		if @coupon.save
			redirect_to admin_offline_coupons_url
		else
			render :new
		end
	end

	def update
		@coupon  = Ecstore::OfflineCoupon.find(params[:id])
		if @coupon.update_attributes(params[:coupon])
			redirect_to admin_offline_coupons_url
		else
			render :edit
		end
	end

	def destroy
		@coupon  = Ecstore::OfflineCoupon.find(params[:id])
		@coupon.destroy

		redirect_to admin_offline_coupons_url
	end

	def downloads
		@coupon  = Ecstore::OfflineCoupon.find(params[:id])
		@downloads = @coupon.coupon_downloads.paginate(:page=>params[:page],:per_page=>20,:order=>"downloaded_at desc")
	end
end
