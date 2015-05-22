#encoding:utf-8
class DistributionsController < ApplicationController
  before_filter :find_user
	layout 'distribution'

	def index
		cat_id = params[:id]
		if cat_id.nil?
			cat_id= 644 #供配商品
		end
	  @cat = Ecstore::Category.find_by_cat_id(cat_id)
     
      @goods =  Ecstore::Good.where("cat_id>=645 and cat_id<=648")#@cat.all_goods
	end

	def cart
		@cart = Ecstore::Good.where("cat_id>=645 and cat_id<=648")

	end

	def bookmark
		@bookmark = Ecstore::Good.where("cat_id>=645 and cat_id<=648")
	end
	
	def orderproducts

	end

	def product
		@goods = Ecstore::Good.find_by_bn(params[:id])
		@sections = @goods.spec_info.split('|')
	end

	def ordernew
	end

	def add_to_cart
		redirect_to cart_distributions_path
	end

	def add_to_bookmark
		redirect_to bookmark_distributions_path
	end

end
