class PagesController < ApplicationController

	layout 'standard'

	def show
		@page = Ecstore::Page.includes(:meta_seo).find(params[:id])

    if @page.supplier_id
      supplier_id = @page.supplier_id
    elsif params[:supplier_id]
      supplier_id = params[:supplier_id]
    end
    
    if supplier_id
      @supplier = Ecstore::Supplier.find(supplier_id)
       return render :layout=>@supplier.layout
    elsif params[:platform] =='vshop'
      render :layout=>'vshop'
    elsif params[:platfom]='mobile'
      render :layout=>'mobile_new'
    else

      render :layout=> @page.layout.present? ? @page.layout : nil
    end

	end



end
