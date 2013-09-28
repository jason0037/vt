#encoding:utf-8
class Admin::GoodsLabelsController < Admin::BaseController
  # GET /admin/cards
  # GET /admin/cards.json
  def index
    @labels = Ecstore::GoodLabel.paginate(:page=>params[:page],:per_page=>20)
  end

  def edit
    @goods_label = Ecstore::GoodLabel.find(params[:id])
  end

  def new
    @goods_label = Ecstore::GoodLabel.new
  end

  def create
    @goods_label = Ecstore::GoodLabel.new
    @goods_label.tag_name = params[:ecstore_good_label][:tag_name]
    @goods_label.tag_bgcolor = params[:color]
    @goods_label.app_id = "b2c"
    @goods_label.save
    redirect_to admin_goods_labels_path
  end

  def updateLabel
    @goods_label = Ecstore::GoodLabel.find(params[:id])
    @goods_label.tag_name = params[:ecstore_good_label][:tag_name]
    @goods_label.tag_bgcolor = params[:color]
    @goods_label.save
    redirect_to admin_goods_labels_path
  end


  def destroy
    @goodsLabel = Ecstore::GoodLabel.find(params[:id])
    @goodsLabel.destroy
    redirect_to admin_goods_labels_path
  end
end
