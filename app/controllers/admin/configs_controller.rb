class Admin::ConfigsController < Admin::BaseController
	def index
		@configs =  Ecstore::Config.all
	end

	def new
		@config  =  Ecstore::Config.new
	end

	def edit
		@config  =  Ecstore::Config.find(params[:id])
	end

	def create
		@config = Ecstore::Config.new(params[:ecstore_config])
		if @config.save
			redirect_to admin_configs_url
		else
			render :new
		end
		
	end

	def update
		@config = Ecstore::Config.find(params[:id])
		if @config.update_attributes(params[:ecstore_config])
			redirect_to admin_configs_url
		else
			render :edit
		end
		
	end
end
