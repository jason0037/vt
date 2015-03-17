class Admin::TagExtsController < Admin::BaseController
	
def index
		key = params[:search][:key] if params[:search] && params[:search][:key]
		#@tags = Ecstore::TagName.where('tag_name rlike ?','z[0-9]{4}').order("tag_id desc")
		@tags = Ecstore::TagName.order("tag_id desc")
		unless key.blank?
			@tags = @tags.where("tag_name like ?","%#{key}%")
		end

		@tags = @tags.paginate(:page=>params[:page],:per_page=>10)
	end

	def edit
		@tag = Ecstore::TagName.find(params[:id])
		@tag_ext = @tag.tag_ext || Ecstore::TagExt.new(:tag_name=>@tag.tag_name,:tag_id=>@tag.tag_id)
	end

	def new
		@tag = Ecstore::TagName.find(params[:id])
		@tag_ext = @tag.tag_ext || Ecstore::TagExt.new(:tag_name=>@tag.tag_name,:tag_id=>@tag.tag_id)
	end

	def update
		@tag_ext = Ecstore::TagExt.find_by_tag_id(params[:id])
		 if @tag_ext
			@tag_ext.update_attributes(params[:ecstore_tag_ext])
		else
			Ecstore::TagExt.create params[:ecstore_tag_ext]
		end

		redirect_to admin_tag_exts_url
	end
end
