#encoding:utf-8
class Store::TuanController < ApplicationController
	layout 'tuan'


  def index
    @supplier=Ecstore::Supplier.find("78")
    @tuan_title="今日团购"
  end


  def wares_details
    @supplier=Ecstore::Supplier.find("78")
    @tuan_title="商品详情"
  end

end
