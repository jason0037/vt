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
    if @user
      @supplier=Ecstore::Supplier.find_by_id("1");
    else
      redirect_to "/auto_login?id=1&supplier_id=1&platform=mobile&return_url=/cheuks/cheuks_goods?supplier_id=1"
      end
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
  def serach
    @supplier=Ecstore::Supplier.find_by_id("1");
  end

end
