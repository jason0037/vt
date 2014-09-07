class PagesController < ApplicationController

	layout 'standard'

	def show
		@page = Ecstore::Page.includes(:meta_seo).find(params[:id])
    if @page.supplier_id
      @supplier = Ecstore::Supplier.find(@page.supplier_id)
      return render :layout=>@supplier.layout
    end
    if params[:platform] =='vshop'
      render :layout=>'vshop'
    elsif params[:platfom]='mobile'
      render :layout=>'mobile_new'
    else

      render :layout=> @page.layout.present? ? @page.layout : nil
    end

	end



end
