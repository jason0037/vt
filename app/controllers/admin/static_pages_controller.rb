class Admin::StaticPagesController < Admin::BaseController

	def index
		@pages =  Ecstore::Page.paginate(:per_page=>20,:page=>params[:page],:order=>"updated_at desc")

      if cookies["MEMBER"]
        @supplier = Ecstore::Supplier.where(:member_id=>cookies["MEMBER"].split("-").first,:status=>1).first
        @pages = @pages.where(:supplier_id=>@supplier.id).paginate(:per_page=>20,:page=>params[:page],:order=>"updated_at desc")
     end

    end

  end

	def new
		@page  = Ecstore::Page.new
		@action_url =  admin_static_pages_path
		@method = :post
	end

	def show
		@page  = Ecstore::Page.find(params[:id])
	end

	def edit
		@page  = Ecstore::Page.find(params[:id])
		@action_url =  admin_static_page_path(@page)
		@method = :put
	end

	def create
		@page  = Ecstore::Page.new params[:page]
		if @page.save
			redirect_to admin_static_pages_url
		else
			render :new
		end
	end

	def update
		@page  = Ecstore::Page.find(params[:id])
		if @page.update_attributes(params[:page])
			redirect_to admin_static_pages_url
		else
			render :edit
		end
	end

	def destroy
		@page  = Ecstore::Page.find(params[:id])
		@page.destroy
		redirect_to admin_static_pages_url
	end
end
