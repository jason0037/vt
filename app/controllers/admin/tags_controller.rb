class Admin::TagsController < Admin::BaseController

	def index
		conditions = nil
		conditions = { :tag_type=>params[:tag_type] } if params[:tag_type] 
		@tags =  Ecstore::Teg.where(conditions).paginate(:per_page=>20,:page=>params[:page],:order=>"tag_id desc")
	end

	def new
		@tag = Ecstore::Teg.new
		@action_url = admin_tags_path
		@method = :post
	end

	def edit
		@tag = Ecstore::Teg.find_by_tag_id(params[:id])
		@action_url = admin_tag_path(@tag)
		@method = :put
	end

	def create
		@tag = Ecstore::Teg.new params[:tag]
		
		if @tag.save
			redirect_to admin_tags_url
		else
			@action_url = admin_tags_path
			@method = :post
			render :new
		end

	end

	def update
		@tag = Ecstore::Teg.find_by_tag_id(params[:id])
		
		if @tag.update_attributes(params[:tag])
			redirect_to admin_tags_url
		else
			@action_url = admin_tag_path(@tag)
			@method = :put
			render :edit
		end
	end

	def destroy
		@tag = Ecstore::Teg.find_by_tag_id(params[:id])
		@tag.destroy

		redirect_to admin_tags_url
	end
end
