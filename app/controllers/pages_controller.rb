class PagesController < ApplicationController

	layout 'standard'

	def show
		@page = Ecstore::Page.includes(:meta_seo).find(params[:id])
		render :layout=> @page.layout.present? ? @page.layout : nil
	end



end
