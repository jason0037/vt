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
			@goods = @goods.where("name like :key or convert(bn,char(20)) like :key",:key=>"%#{key}%")
		end

		@goods = @goods.paginate(:per_page=>per_page,:page=>page)
	end

end
