#encoding:utf-8
class Admin::BrandAdmsController < Admin::BaseController

  def index
    @brands = Ecstore::Brand.paginate(:page=>params[:page],:per_page=>30)
  end

  def new
    @brand  = Ecstore::Brand.new
    @action_url =  admin_brand_adms_path
    @method = :post
  end

  def edit
    @brand = Ecstore::Brand.find(params[:id])
    @action_url =  admin_brand_adm_path(@brand)
    @method = :put
  end

  def create
    @brand  = Ecstore::Brand.new params[:brand]
    if @brand.save
      redirect_to admin_brand_adms_url
    else
      @action_url =  admin_brand_adms_path
      @method = :post
      render :new
    end
  end

  def update
    @brand  = Ecstore::Brand.find(params[:id])
    if @brand.update_attributes(params[:brand])
      redirect_to admin_brand_adms_url
    else
      @action_url =  admin_brand_adm_path(@brand)
      @method = :put
      render :edit
    end
  end

  def destroy
    @brand  = Ecstore::Footer.find(params[:id])
    @brand.destroy
    redirect_to admin_brand_adms_url
  end
end
