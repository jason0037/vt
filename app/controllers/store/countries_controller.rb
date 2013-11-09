class Store::CountriesController < ApplicationController
	# layout 'magazine'
      layout 'standard'
  	# before_filter :require_top_cats
  	
  	def show
        country_name = Ecstore::Country.find_by_country_id(params[:id]).country_name
        conditions = {:place=>country_name}
        if params[:gtype] == "1"
             conditions["sell"] = 'true' 
        elsif params[:gtype] == "2"
             conditions["future"] = 'true'
        elsif params[:gtype] == "3"
             conditions["agent"] = 'true'
        end
        conditions.each do |key,val|
          raise "Field `#{key}`  is existence" unless Ecstore::Good.attribute_names.include?(key.to_s)
        end if conditions.present?

        @all_goods = Ecstore::Good.where(conditions).order("d_order desc").to_a 

        order = params[:order]

        if order.present?
            col, sorter = order.split("-")
        end
              
        page  =  (params[:page] || 1).to_i
        per_page = 18

            
        if col&&sorter == 'asc'
            @goods = @all_goods.sort{ |x,y| x.attributes[col] <=> y.attributes[col] }.paginate(page,per_page)
        elsif col&&sorter == 'desc'
            @goods = @all_goods.sort{ |x,y| y.attributes[col] <=> x.attributes[col] }.paginate(page,per_page)
        else
            @goods = @all_goods.sort{ |x,y| y.uptime <=> x.uptime }.paginate(page,per_page)
        end     
    end
end
