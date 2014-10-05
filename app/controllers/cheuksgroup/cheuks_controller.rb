class Cheuksgroup::CheuksController < ApplicationController
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

  def  technical       #技术中心
    @supplier=Ecstore::Supplier.find_by_id("1");
  end

  def content
    @supplier=Ecstore::Supplier.find_by_id("1");

  end
 def map
   @supplier=Ecstore::Supplier.find_by_id("1");
 end

  def industry_trends
    @supplier=Ecstore::Supplier.find_by_id("1");

  end

  def industry_detail
    @supplier=Ecstore::Supplier.find_by_id("1");

  end

end
