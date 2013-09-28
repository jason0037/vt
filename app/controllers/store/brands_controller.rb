class Store::BrandsController < ApplicationController
  # layout 'magazine'
  layout 'standard'
  before_filter :require_top_cats

  def index
    @brands = Ecstore::Brand.order("ordernum asc,slug asc")
    @reco =  Ecstore::Brand.where(:reco=>true).first
  end

  def show

  	@brand = Ecstore::Brand.find(params[:id])
       
  	@brand_page = @brand.brand_page
      return if @brand.status == 'disabled'

       page  =  (params[:page] || 1).to_i
       per_page = 18

  	order = params[:order]
  	if order.present?
             col, sorter = order.split("-")
  		order = order.split("-").join(" ");
  	else
             order = "uptime desc"
      end

       if params[:cat_id].present?
          page  = (params[:page] || 1).to_i 
          @cat  =  Ecstore::Category.find(params[:cat_id])
          @all_goods = @cat.all_goods( { :brand_id=>@brand.brand_id } )
        
          if col&&sorter == 'asc'
              @goods = @all_goods.sort{ |x,y| x.attributes[col] <=> y.attributes[col] }.paginate(page,per_page)
          elsif col&&sorter == 'desc'
              @goods = @all_goods.sort{ |x,y| y.attributes[col] <=> x.attributes[col] }.paginate(page,per_page)
          else
              @goods = @all_goods.sort{ |x,y| y.uptime <=> x.uptime }.paginate(page,per_page)
          end
       else
          @goods =  @brand.goods.paginate(:page=>page,:per_page=>per_page,:order=>order)
       end

  	
  end

end
