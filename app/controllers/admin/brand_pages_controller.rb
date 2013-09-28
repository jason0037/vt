class Admin::BrandPagesController < Admin::BaseController

  def index
    if params[:scope] == 'unscoped'
        @brands =  Ecstore::Brand.unscoped.order("ordernum asc,slug asc")
    else
        @brands =  Ecstore::Brand.order("ordernum asc,slug asc")
    end
    
    if params[:search]
        key =  params[:search][:key]
        @brands = @brands.where("brand_name like ?","%#{key}%").paginate(:page=>params[:page],:per_page=>20)
    else
        @brands = @brands.paginate(:page=>params[:page],:per_page=>20)
    end

  end

  def new
    
  end
  
  def edit
     @brand = Ecstore::Brand.find(params[:id])
     @brand_page = @brand.brand_page
     if @brand_page
        @action_url  = admin_brand_page_path(@brand_page)
        @method = :put
     else
         @action_url  = admin_brand_pages_path
         @method = :post
         render :new
     end
  end

  def update
      @brand = Ecstore::Brand.find_by_brand_id(params[:brand_page][:brand_id])
      @brand.update_attributes params[:brand]

      @brand_page = Ecstore::BrandPage.find(params[:id])
      if @brand_page.update_attributes(params[:brand_page])
          redirect_to edit_admin_brand_page_url(@brand)
      else
          render :edit
      end 
  end

  def create
      @brand = Ecstore::Brand.find_by_brand_id(params[:brand_page][:brand_id])
      @brand.update_attributes params[:brand]

      @brand_page = Ecstore::BrandPage.new(params[:brand_page])
      if @brand_page.save
          redirect_to edit_admin_brand_page_url(@brand)
      else
          render :new
      end 
  end

  def destroy
      @brand_page = Ecstore::BrandPage.find(params[:id])
      @brand_page.destroy
      redirect_to admin_brand_pages_url
  end

  def toggle
    return_url =  request.env["HTTP_REFERER"]
    return_url =  admin_brand_pages_url if return_url.blank?

    @brand = Ecstore::Brand.unscoped.find(params[:id])
    val = @brand.disabled == 'false' ? 'true' : 'false'
    @brand.update_attribute :disabled, val
    redirect_to return_url
  end

  def order
    @brand = Ecstore::Brand.find(params[:id])
    @brand.update_attribute :ordernum,params[:ordernum].to_i
    render :nothing=>true
  end

  def reco
    return_url =  request.env["HTTP_REFERER"]
    return_url =  admin_brand_pages_url if return_url.blank?
    
    @brand = Ecstore::Brand.find(params[:id])
    Ecstore::Brand.where(:reco=>true).update_all :reco=>false
    @brand.update_attribute :reco, true
    redirect_to return_url
  end

end
