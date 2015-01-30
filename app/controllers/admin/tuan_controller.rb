module Admin
  class TuanController < Admin::BaseController
    skip_before_filter :require_permission!

    def index
      @goodspromotion_ref = Ecstore::Rule.paginate(:page => params[:page], :per_page => 20).order("to_time DESC")

    end

    def new
      @goodspromotion_ref = Ecstore::GoodsPromotionRef.new
      @method = :post
      @action_url = admin_rules_path
    end

    def create
      @goodspromotion_ref = Ecstore::GoodsPromotionRef.new(params[:goodspromotion_ref]) do  |ru|
        ru.create_time=Time.now
        ru.from_time=Time.parse(params[:rules][:from_time]).to_i
        ru.to_time=Time.parse(params[:rules][:to_time]).to_i

      end
      @rules.save
      redirect_to admin_rules_url
    end
    def edit
      @goodspromotion_ref = Ecstore::GoodsPromotionRef.find(params[:id])
    end

    def update
      @goodspromotion_ref = Ecstore::GoodsPromotionRef.find(params[:id])
      if   @goodspromotion_ref .update_attributes(params[:goodspromotion_ref])
        redirect_to  admin_categories_url
      else
        render "edit"
      end
    end

    def show

    end








  end
end