#encoding:utf-8
class Store::TuanController < ApplicationController
	layout 'tuan'


  def index
    @supplier=Ecstore::Supplier.find("78")
    @tuan_title="团购&预售"
   # @tuan=Ecstore::GoodsPromotionRef.where(:status=>"true").order("to_time asc")
   @tuan=Ecstore::Good.where("goods_id>=26171 and goods_id<=26178").order("p_order")
  end


  def wares_details
    @supplier=Ecstore::Supplier.find("78")
    @good=Ecstore::Good.find(params[:goods_id])
    #@tuan=Ecstore::GoodsPromotionRef.where(:status=>"true",:goods_id=>params[:goods_id]).first
    @tuan=Ecstore::Good.where(:goods_id=>params[:goods_id])
    @tuan_title="商品详情"
  end

end
