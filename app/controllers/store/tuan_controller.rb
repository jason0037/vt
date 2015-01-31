#encoding:utf-8
class Store::TuanController < ApplicationController
	layout 'tuan'


  def index
    @supplier=Ecstore::Supplier.find("78")
    @tuan_title="今日团购"
    @tuan=Ecstore::GoodsPromotionRef.where(:status=>"true").order("to_time asc")
  end


  def wares_details
    @supplier=Ecstore::Supplier.find("78")
    @good=Ecstore::Good.find(params[:goods_id])
    @tuan=Ecstore::GoodsPromotionRef.where(:status=>"true",:goods_id=>params[:goods_id]).first
    @tuan_title="商品详情"
  end

end
