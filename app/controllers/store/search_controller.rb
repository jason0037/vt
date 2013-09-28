#encoding:utf-8
class Store::SearchController < ApplicationController

	layout 'standard'

	def index
		page  =  (params[:page] || 1).to_i
		per_page = 20

		q = params[:q].strip
		q = q.gsub(/[\s,\.\*\+\/\-:'"!\&\^\[\]\(\)， 。：”’（）%@！、]+/,"%")
		@splits = q.split(/%+/)

		order = params[:order]
	  	if order.present?
	             col, sorter = order.split("-")
	  		order = order.split("-").join(" ")
	  	else
	             order = "uptime desc"
	       end

		@goods = Ecstore::Good.selling.order(order)

		@splits.each do |key|
			@goods = @goods.joins(:brand).where("name like :key or brand_name like :key",:key=>"%#{key}%")
		end

		@goods = @goods.includes(:brand).paginate(:per_page=>per_page,:page=>page)
	end

end
