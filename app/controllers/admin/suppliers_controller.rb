class Admin::SuppliersController < ApplicationController
	layout 'admin'

	def index
		@suppliers = Ecstore::Supplier.paginate(:page => params[:page], :per_page => 20).order("status DESC,created_at DESC")
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
    uploaded_io = params[:license_file]
    if !uploaded_io.blank?
      extension = uploaded_io.original_filename.split('.')
      filename = "#{Time.now.strftime('%Y%m%d%H%M%S')}.#{extension[-1]}"
      filepath = "#{PIC_PATH}/vshop_docs/#{filename}"
      File.open(filepath, 'wb') do |file|
        file.write(uploaded_io.read)
      end
     # params[:supplier].merge!(:license=>"/images/vshop_docs/#{filename}")
    end


    params[:supplier].merge!(:member_id=>@user.id)
		@supplier = Ecstore::Supplier.new(params[:supplier])
		if @supplier.save
      return_url= params[:return_url]
      if (return_url.blank?)
			redirect_to admin_suppliers_url
      else
        redirect_to "#{return_url}?step=2&id=#{@supplier.id}"
      end
		else
			render :new
		end
		
	end

	def update
    #return render :text=>params[:supplier][:layout]
		@supplier = Ecstore::Supplier.find(params[:id])
		
		if @supplier.update_attributes(params[:supplier])
      return_url= params[:return_url]
      if return_url
        redirect_to "#{return_url}?step=3"
      else
        redirect_to admin_suppliers_url
      end

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
