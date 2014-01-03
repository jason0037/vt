#encoding:utf-8
class Patch::AftersalesController < ApplicationController
	layout 'patch'
	
	before_filter do
		clear_breadcrumbs
		add_breadcrumb("我的贸威",:member_path)
	end

	def index
		@orders = @user.aftersale_orders.paginate(:per_page=>10,:page=>params[:page])
		add_breadcrumb("申请售后服务")
	end

	def instruction
		add_breadcrumb("售后服务说明")
	end


	def new
		add_breadcrumb("申请售后服务")
		@order =  @user.orders.find_by_order_id(params[:order_id])
		unless @order
			return render(:inline=>"<p>找不到订单<p>",:layout=>"patch",:status=>:forbidden)
		end
		if @order.aftersale
			return render(:inline=>"<p>无法申请售后服务<p>",:layout=>"patch",:status=>:forbidden)
		end
		@aftersale = Ecstore::Aftersale.new
	end


	def show
		@aftersale = Ecstore::Aftersale.find(params[:id])

		add_breadcrumb("查看售后服务申请")
	end

	def create
		params[:aftersale].merge!(:member_id=>@user.member_id)
		params[:aftersale].merge!(:add_time=>Time.now.to_i)
		@aftersale = Ecstore::Aftersale.new(params[:aftersale])
		if @aftersale.save
			render :text=>"售后服务申请已发送！", :layout=>"patch"
		else
			@order =  Ecstore::Order.find_by_order_id(@aftersale.order_id)
			render :new
		end
	end

	def destroy

	end
end
