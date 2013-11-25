class Admin::SuppliersController < ApplicationController
	layout 'admin'

	def index
		@suppliers = Ecstore::Supplier.paginate(:page => params[:page], :per_page => 20).order("created_at DESC")
	end


	def show

	end

	def new
		@supplier  =  Ecstore::Supplier.new
		@action_url =  admin_suppliers_path
    	@method = :post
	end

	def edit
		@supplier  =  Ecstore::Supplier.find(params[:id])
		@action_url = admin_supplier_path(@supplier)
		@method = :put
	end

	def create
		@supplier = Ecstore::Supplier.new(params[:supplier])
		if @supplier.save
			redirect_to admin_suppliers_url
		else
			render :new
		end
		
	end

	def update
		@supplier = Ecstore::Supplier.find(params[:id])
		
		if @supplier.update_attributes(params[:supplier])
			redirect_to admin_suppliers_url
		else
			@action_url = admin_supplier_path(@supplier)
			@method = :put
			render :edit
		end
	end

	def destroy
		@supplier = Ecstore::Supplier.find(params[:id])
		@supplier.destroy

		redirect_to admin_suppliers_url
	end
end
