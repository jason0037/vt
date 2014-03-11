class Store::CatsController < ApplicationController
	# layout 'magazine'
      layout 'standard'
  	before_filter :require_top_cats
  	
  	def show
  	      @cat = Ecstore::Category.find_by_cat_id(params[:id])
          if params[:gtype] == "1"
             @all_goods = @cat.all_goods(:sell=>"true")
          elsif params[:gtype] == "2"
             @all_goods = @cat.all_goods(:future=>"true")
          elsif params[:gtype] == "3"
             @all_goods = @cat.all_goods(:agent=>"true")
          end

      		order = params[:order]

    	  	if order.present?
    	  		col, sorter = order.split("-")
          else
            col, sorter =  %w{goods_id desc}
    	  	end
              
             page  =  (params[:page] || 1).to_i
             per_page = 18

             if params[:brand].to_i > 0
                  @all_goods.select! {|g| g.brand_id == params[:brand].to_i }
             end

             if params[:color].to_i > 0
                  @all_goods.select! { |g| g.color_specs('id').include? params[:color].to_i }
             end

            
             if col&&sorter == 'asc'
                  @goods = @all_goods.sort{ |x,y| x.attributes[col] <=> y.attributes[col] }.paginate(page,per_page)
             elsif col&&sorter == 'desc'
                  @goods = @all_goods.sort{ |x,y| y.attributes[col] <=> x.attributes[col] }.paginate(page,per_page)
             else
                 # @goods = @all_goods.sort{ |x,y| y.uptime <=> x.uptime }.paginate(page,per_page)
               @goods = @all_goods.paginate(page,per_page)
             end

             # @menu_brands = Hash.new
             # @all_goods.each do |g|
             #    if g.brand
             #      @menu_brands[g.brand_id] = @menu_brands[g.brand_id].to_i + 1
             #    end
             # end

             # @menu_colors = Hash.new
             # @all_goods.each do |g|
             #      g.color_specs.each do |spec_value|
             #          @menu_colors[spec_value.spec_value_id] = @menu_colors[spec_value.spec_value_id].to_i + 1
             #      end
             # end

      end
end
