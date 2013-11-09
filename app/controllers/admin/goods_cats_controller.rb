#encoding:utf-8
class Admin::GoodsCatsController < Admin::BaseController
  # GET /admin/cards
  # GET /admin/cards.json
  def index
    @top_cats = Ecstore::GoodCat.where(:parent_id=>0).paginate(:page=>params[:page],:per_page=>30)
  end

  def edit
    @goods_cat = Ecstore::GoodCat.find(params[:id])
  end

  def create_top
  end

  def toggle_future
    return_url =  request.env["HTTP_REFERER"]
    return_url =  admin_good_cats_url if return_url.blank?
    @cat = Ecstore::GoodCat.find(params[:id])
    pp @cat
    val = @cat.future == 'false' ? 'true' : 'false'
    @cat.update_attribute :future, val
    redirect_to return_url
  end

  def toggle_agent
    return_url =  request.env["HTTP_REFERER"]
    return_url =  admin_good_cats_url if return_url.blank?
    @cat = Ecstore::GoodCat.find(params[:id])
    pp @cat
    val = @cat.agent == 'false' ? 'true' : 'false'
    @cat.update_attribute :agent, val
    redirect_to return_url
  end

  def toggle_sell
    return_url =  request.env["HTTP_REFERER"]
    return_url =  admin_good_cats_url if return_url.blank?
    @cat = Ecstore::GoodCat.find(params[:id])
    val = @cat.sell == 'false' ? 'true' : 'false'
    @cat.update_attribute :sell, val
    redirect_to return_url
  end

  def save_top
      @goodcat = Ecstore::GoodCat.new
      @goodcat.cat_name = params[:goods_cat][:cat_name]
      @goodcat.type_id = params[:goods_cat][:type]
      @goodcat.parent_id = 0
      @goodcat.cat_path = ","

      if @goodcat.save
        redirect_to admin_goods_cats_path
      else
        render "new"
      end
  end

  def create
      @goodcat = Ecstore::GoodCat.new
      @goodcat.cat_name = params[:goods_cat][:cat_name]
      @goodcat.type_id = params[:goods_cat][:type]
      @goodcat.parent_id =params[:goods_cat][:cat]
      path = Ecstore::GoodCat.find(params[:goods_cat][:cat]).cat_path
      @goodcat.cat_path = path + params[:goods_cat][:cat] + ","

      if @goodcat.save
        redirect_to edit_admin_goods_cat_url(@goodcat)
      else
        render "new"
      end
  end

  def update
    @goodcat = Ecstore::GoodCat.find(params[:id])
    if @goodcat.update_attributes(params[:ecstore_good_cat])
      redirect_to edit_admin_goods_cat_url(@goodcat)
    else
      render action: "edit"
    end
  end

  def destroy
    @goodcat = Ecstore::GoodCat.find(params[:id])
    @goodcat.destroy
    redirect_to admin_goods_cats_path
  end
end
