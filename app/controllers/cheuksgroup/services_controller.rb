class Cheuksgroup::ServicesController < ApplicationController
  layout "cheuks"
  def index
    @supplier=Ecstore::Supplier.find_by_id("1");

  end
  def services_center
    @supplier=Ecstore::Supplier.find_by_id("1");

  end
  def services_detail
    @supplier=Ecstore::Supplier.find_by_id("1");

  end
end
