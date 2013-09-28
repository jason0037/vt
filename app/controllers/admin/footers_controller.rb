class Admin::FootersController < Admin::BaseController

	def index
		@footers =  Ecstore::Footer.paginate(:per_page=>20,:page=>params[:page],:order=>"updated_at desc")
	end

	def new
		@footer  = Ecstore::Footer.new
		@action_url =  admin_footers_path
		@method = :post
	end

	def show
		@footer  = Ecstore::Footer.find(params[:id])
	end

	def edit
		@footer  = Ecstore::Footer.find(params[:id])
		@action_url =  admin_footer_path(@footer)
		@method = :put
	end

	def create
		@footer  = Ecstore::Footer.new params[:footer]
		if @footer.save
			redirect_to admin_footers_url
		else
			render :new
		end
	end

	def update
		@footer  = Ecstore::Footer.find(params[:id])
		if @footer.update_attributes(params[:footer])
			redirect_to admin_footers_url
		else
			render :edit
		end
	end

	def destroy
		@footer  = Ecstore::Footer.find(params[:id])
		@footer.destroy
		redirect_to admin_footers_url
	end
end
