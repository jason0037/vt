#encoding:utf-8
class Patch::MemberAddrsController < ApplicationController
	# layout 'standard'
	layout "patch"

	before_filter do
		clear_breadcrumbs
		add_breadcrumb("我的贸威",:member_path)
	end

	def new
		@addr = Ecstore::MemberAddr.new
	end

	def index
		@addrs = @user.member_addrs.paginate(:per_page=>10,:page=>params[:page])
		add_breadcrumb("收货地址")
	end

	def edit
		@addr = Ecstore::MemberAddr.find(params[:id])
		@method = :put
		@action_url = member_addr_path(@addr)

		respond_to do |format|
			format.html
			format.js
		end
	end

	def create
		@addr = Ecstore::MemberAddr.new params[:addr].merge!(:member_id=>@user.member_id)
    return_url=params[:return_url]
		if @addr.save
      redirect_to '/orders/new_mobile'
=begin
      if return_url
        redirect_to return_url
      else
        respond_to do |format|
          format.js
          format.html { redirect_to member_addrs_url }
        end
			end
=end
		else
			render "error.js" #, status: :unprocessable_entity
		end
	end

	def update
		@addr = Ecstore::MemberAddr.find(params[:id])
		if @addr.update_attributes(params[:addr])
			respond_to do |format|
				format.js
				format.html { redirect_to member_addrs_url }
			end
		else
			render 'error.js' #, status: :unprocessable_entity
		end
	end

	def destroy
		@addr = Ecstore::MemberAddr.find(params[:id])
		@addr.destroy
		redirect_to member_addrs_url
	end


end
