class CheuksController < ApplicationController
  layout "cheuks"
  def index
    @supplier=Ecstore::Supplier.find_by_id("1");

  end

  def news
    @supplier=Ecstore::Supplier.find_by_id("1");
  end

  def new_detail
    @supplier=Ecstore::Supplier.find_by_id("1");
  end

  def cheuks_goods
    @supplier=Ecstore::Supplier.find_by_id("1");
  end
end
