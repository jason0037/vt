class Cheuksgroup::TechnicalsController < ApplicationController

  layout "cheuks"

  def index
    @supplier=Ecstore::Supplier.find_by_id("1");

  end

  def product_standards    ###产品标准
    @supplier=Ecstore::Supplier.find_by_id("1");
  end

  def product_detail     ###
    @supplier=Ecstore::Supplier.find_by_id("1");
  end

  def failure_analysis
    @supplier=Ecstore::Supplier.find_by_id("1");
  end


  def failure_detail
    @supplier=Ecstore::Supplier.find_by_id("1");
  end

  def use_experience
    @supplier=Ecstore::Supplier.find_by_id("1");

  end
  def use_detail
    @supplier=Ecstore::Supplier.find_by_id("1");

  end
end
