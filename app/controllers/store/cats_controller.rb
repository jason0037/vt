#encoding:utf-8
class Store::CatsController < ApplicationController
	# layout 'magazine'
    layout 'standard'
  	before_filter :require_top_cats

  def index
    supplier_id=params[:supplier_id]
    if supplier_id == nil
      supplier_id = 78
    end
    @supplier = Ecstore::Supplier.find(supplier_id)
    @cats = Ecstore::Category.where(:parent_id=>0)
    respond_to do  |format|
        format.mobile { render :layout=> 'msite'}
    end
  end

  def show_mobile

       @supplier = Ecstore::Supplier.find(params[:id])
        name= params[:name]

        goods_ids =""
        sql = "select replace(replace(replace(field_vals,'---\n- ',''''),'- ',','''),'\n','''') as goods_ids FROM mdk.sdb_imodec_promotions where name='#{name}'"
        results = ActiveRecord::Base.connection.execute(sql)
        results.each(:as => :hash) do |row|
          goods_ids= row["goods_ids"]
        end

        sql = " bn in (#{goods_ids})"

        @goods = Ecstore::Good.where(sql)
        @goods = @goods.order("p_order asc,uptime desc")
        render :layout=>@supplier.layout

  end

  def goods_list
    @cat = Ecstore::Category.find_by_cat_id("")

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

  #金芭浪团购
  def  show_group
    name= params[:name]

    goods_ids =""
    sql = "select replace(replace(replace(field_vals,'---\n- ',''''),'- ',','''),'\n','''') as goods_ids FROM mdk.sdb_imodec_promotions where name='#{name}'"
    results = ActiveRecord::Base.connection.execute(sql)
    results.each(:as => :hash) do |row|
      goods_ids= row["goods_ids"]
    end

    sql = " bn in (#{goods_ids})"
    @all_goods = Ecstore::Good.where(sql)
    @goods = @all_goods
    render :layout=>'tairyo_new'
  end

  def list_spec
      tag_id = params[:id]
      @gallery = Ecstore::TagExt.where(:tag_id=>tag_id).first
      if @gallery.nil?
        return render :text=>"敬请期待"
      end
      @categories = Ecstore::Category.where("cat_id in (#{@gallery.categories})").order("p_order")

      respond_to do |format|
          format.mobile { render :layout=> 'msite'}
      end
  end

  def show
      supplier_id=params[:supplier_id]
      if supplier_id == nil
        supplier_id = 78
      end
      @supplier = Ecstore::Supplier.find(supplier_id)
      
      @cat = Ecstore::Category.find_by_cat_id(params[:id])
      case params[:gtype]
        when "2"
          @all_goods = @cat.all_goods(:future=>"true")
        when "3"
          @all_goods = @cat.all_goods(:agent=>"true")
        else
          @all_goods = @cat.all_goods(:sell=>"true")
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
        respond_to do  |format|
            format.mobile { render :layout=> 'msite'}
        end
    end
end

