#encoding:utf-8
require 'sms'
class Store::OfflineCouponsController < ApplicationController
	layout 'standard'
	def show
		@coupon  =  Ecstore::OfflineCoupon.includes(:brand).find(params[:id])
		return render :text=>"对不起,没有找到该优惠券!",:layout=>"standard" unless @coupon.published
		@brand = @coupon.brand
		@newin_vgoods = Ecstore::VirtualGood.where(:marketable=>true).order("uptime desc").limit(4)
		@maybe_coupons = Ecstore::OfflineCoupon.where("id <> ?", @coupon.id).limit(4)
	end

	def download
		tel = params[:sms][:mobile]

		return render :js=>"alert('请输入手机号码')" if tel.blank?
		# @user.member_id
		@coupon =  Ecstore::OfflineCoupon.find(params[:id])
		# unless @coupon.enable_of(@user)
			
		# end

		begin
		  Sms.send(tel,@coupon.sms_text)
		  @coupon.increment!(:download_times)

		  Ecstore::CouponDownload.new({
		  	  :member_id=>@user.member_id,
		  	  :offline_coupon_id=>@coupon.id,
		  	  :downloaded_at=>Time.now
		  }).save

		  render "download"
		rescue
		  render "error"
		end
	end
end
