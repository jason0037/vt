class Store::VirtualGoodsController < ApplicationController
	layout 'standard'
	def index
	end

	def show
		@vgood = Ecstore::VirtualGood.includes(:cat,:brand).find(params[:id])
		@cat  =  @vgood.cat
		@brand = @vgood.brand if @vgood
		@coupon = @brand.offline_coupon if @brand
		@newin_vgoods = Ecstore::VirtualGood.where("id <> ? and marketable = ?",@vgood.id,true).order("uptime desc").limit(4)
	end
end
