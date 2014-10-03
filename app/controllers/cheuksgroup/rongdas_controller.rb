class Cheuksgroup::RongdasController < ApplicationController
  layout "cheuks"

  def index
    @supplier=Ecstore::Supplier.find_by_id("1");

  end
  def rongda
    @supplier=Ecstore::Supplier.find_by_id("1");
  end


  def rongda_goods
    @supplier=Ecstore::Supplier.find_by_id("1");
  end

  def goods_detail
    @supplier=Ecstore::Supplier.find_by_id("1");

  end

  def order_rongda
    @supplier=Ecstore::Supplier.find_by_id("1");

  end
end
