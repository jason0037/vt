class Store::SuppliersController < ApplicationController
	# layout 'magazine'
      layout 'standard'
  	# before_filter :require_top_cats
  	
  	def show
        @supplier = Ecstore::Supplier.find(params[:id])   
    end
end
