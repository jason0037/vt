class Admin::VirtualGoodsController < Admin::BaseController
	
	def index
		@vgoods = Ecstore::VirtualGood.paginate(:page=>params[:page],:per_page=>20)
	end

	def new
		@vgood =  Ecstore::VirtualGood.new
		@action_url = admin_virtual_goods_path
		@method = :post
	end

	def edit
		@vgood =  Ecstore::VirtualGood.find(params[:id])
		@action_url = admin_virtual_good_path(@vgood)
		@method = :put
	end

	def create
		@vgood = Ecstore::VirtualGood.new params[:vgood]
		if @vgood.save
			redirect_to admin_virtual_goods_url
		else
			@action_url = admin_virtual_goods_path
			@method = :post
			render :new
		end
	end
	
	def update
		@vgood = Ecstore::VirtualGood.find(params[:id])
		if @vgood.update_attributes(params[:vgood])
			redirect_to admin_virtual_goods_url
		else
			@action_url = admin_virtual_good_path(@vgood)
			@method = :put
			render :edit
		end
	end

	def destroy
		@vgood = Ecstore::VirtualGood.find(params[:id])
		@vgood.destroy
		redirect_to admin_virtual_goods_url 
	end

	def import
		file = params[:vgood][:file].tempfile
		result  =  Ecstore::VirtualGood.import(file)
		
		flash[:result] = result

		redirect_to admin_virtual_goods_url
	end

end
