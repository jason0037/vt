require 'csv'

class Admin::NewCouponsController < Admin::BaseController

	def index
		@coupons = Ecstore::NewCoupon.paginate(:per_page=>10,:page=>params[:page],:order=>"created_at asc")
	end

	def new
		@coupon  = Ecstore::NewCoupon.new
		@action_url = admin_new_coupons_path
		@method = :post
	end

	def show
		@coupon  = Ecstore::NewCoupon.find(params[:id])
	end

	def edit
		@coupon  = Ecstore::NewCoupon.find(params[:id])
		@action_url = admin_new_coupon_path(@coupon)
		@method = :put
	end

	def create
		params[:coupon][:coupon_prefix] = params[:coupon][:coupon_type] + params[:coupon][:coupon_prefix] 
		@coupon  = Ecstore::NewCoupon.new(params[:coupon])

		if @coupon.save
			redirect_to admin_new_coupons_url
		else
			render :new
		end
	end

	def update
		params[:coupon][:coupon_prefix] = params[:coupon][:coupon_type] + params[:coupon][:coupon_prefix] 
		@coupon  = Ecstore::NewCoupon.find(params[:id])
		if @coupon.update_attributes(params[:coupon])
			redirect_to admin_new_coupons_url
		else
			render :edit
		end
	end

	def destroy
		@coupon  = Ecstore::NewCoupon.find(params[:id])
		@coupon.destroy

		redirect_to admin_new_coupons_url
	end


	def download
		@coupon =  Ecstore::NewCoupon.find(params[:id])
		count = (params[:count] || 50).to_i

		file_name = "coupons_#{Time.now.to_i}.csv"
		download_file = "#{Rails.root}/public/tmp/#{file_name}"

		CSV.open(download_file,"wb") do |csv|
			count.times do
				csv << [@coupon.generate_coupon_code(true)]
			end
		end

		render :text => "/tmp/#{file_name}"
	end

	def select_coupons

		@coupons = Ecstore::NewCoupon.paginate(:per_page=>20,:page=>params[:page])
		
		respond_to do |format|
	            format.html { render :layout=> "dialog" }
	            format.js
	      end
	end
	
end
