class Admin::CategoriesController < ApplicationController
	layout 'dialog'

	def index
		@categories = Imodec::Category.all
	end

	def edit
		@category = Imodec::Category.find(params[:id])
	end

	def update
		@category = Imodec::Category.find(params[:id])
		if @category.update_attributes(params[:imodec_category])
			redirect_to  admin_categories_url
		else
			render "edit"
		end
	end

	def create
		@category = Imodec::Category.new(params[:category])
		@category.save
		redirect_to admin_categories_url
	end

	def destroy
		@category = Imodec::Category.find(params[:id])
		@category.destroy
		redirect_to admin_categories_url
	end
end
