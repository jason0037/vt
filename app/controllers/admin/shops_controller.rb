
#encoding:utf-8

module Admin
  class ShopsController < Admin::BaseController
    skip_before_filter :require_permission!
    def index
      @shops = Ecstore::Shop.paginate(:page => params[:page], :per_page => 20).order("created_at DESC")

    end

    def edit
     @shop = Ecstore::Shop.find(params[:id])
     @shop_desc = Ecstore::ShopLog.find(params[:id]).shop_desc
    end

    def update
      shop_desc=params[:shop_desc]
      Ecstore::ShopLog.find(params[:id]).update_attributes(:shop_desc=>shop_desc)
      @shop = Ecstore::Shop.find(params[:id])
      if @shop.update_attributes(params[:shop])
        redirect_to  admin_shops_url
      else
        render "edit"
      end
    end

    def create
      @shop = Ecstore::Shop.new(params[:shop])

      @shop.save
      redirect_to admin_shops_url
    end

    def detail
      shop_id=params[:shop_id]
      @shop = Ecstore::Shop.find(shop_id)
     @shop_user=Ecstore::ShopClient.where(:shop_id=>shop_id)
      @shop_order=Ecstore::Order.where(:shop_id=>shop_id)
    end

    def destroy
      shop_id=params[:id]
      @shop = Ecstore::Shop.find(shop_id)

      # @shop.destroy
      @shop.update_attribute(:status,-1);
      redirect_to admin_shops_url
    end
  end
end