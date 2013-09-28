class Admin::LabelsController < Admin::BaseController
	layout 'dialog'

	def index
		@labels = Ecstore::Label.all
	end

	def edit
		@label = Ecstore::Label.find(params[:id])
	end

	def update
		@label = Ecstore::Label.find(params[:id])
		if @label.update_attributes(params[:ecstore_label])
			redirect_to  admin_labels_url
		else
			render "edit"
		end
	end

	def create
		@label = Ecstore::Label.new(params[:label])
		@label.save
		redirect_to admin_labels_url
	end

	def destroy
		@label = Ecstore::Label.find(params[:id])
		@label.destroy
		redirect_to admin_labels_url
	end
end
