class Admin::TuansController < Admin::BaseController
  skip_before_filter :require_permission!

  def index
    @goodspromotion_ref = Ecstore::GoodsPromotionRef.paginate(:page => params[:page], :per_page => 20).order("to_time DESC")
    @goodspromotion_ref =@goodspromotion_ref.where("to_time>UNIX_TIMESTAMP(now()) ")
  end

  def new
    @goodspromotion_ref = Ecstore::GoodsPromotionRef.new
    @method = :post
    @action_url = admin_tuans_path
  end

  def create
    @goodspromotion_ref = Ecstore::GoodsPromotionRef.new(params[:ecstore_goods_promotion_ref]) do  |ru|

      ru.from_time=Time.parse(params[:ecstore_goods_promotion_ref][:from_time]).to_i
      ru.to_time=Time.parse(params[:ecstore_goods_promotion_ref][:to_time]).to_i

    end

    @goodspromotion_ref.save

    @goodspromotion_ref.good.update_attributes(:shopstatus=>"false")

    redirect_to admin_tuans_path
  end
  def edit

    @goodspromotion_ref = Ecstore::GoodsPromotionRef.find(params[:ref_id])
    @method = :post
    @action_url = admin_tuans_path
  end

  def update
    from_time= Time.parse(params[:ecstore_goods_promotion_ref].delete(:from_time)).to_i
    to_time= Time.parse(params[:ecstore_goods_promotion_ref].delete(:to_time)).to_i



    @goodspromotion_ref = Ecstore::GoodsPromotionRef.find(params[:ref_id])
    if   @goodspromotion_ref.update_attributes(params[:ecstore_goods_promotion_ref].merge!(:from_time=>from_time,:to_time=>to_time))
      redirect_to  admin_tuans_path
    else
      render "edit"
    end
  end

  def show

  end









end
