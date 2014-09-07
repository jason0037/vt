#encoding:utf-8
class CommissionsController < ApplicationController

  layout "vshop"

  #计算佣金,默认为当月
  def caculate
    yeah_month =params[:yearmonth]
   if yeah_month==nil
     yeah_month=Time.now.strftime('%Y-%m')
   end
    @commission = Ecstore::Commission.new
  end

  def login

  end

  def register

  end

  def apply
    if params[:id]
      @supplier  =  Ecstore::Supplier.find(params[:id])
      @action_url =  "/admin/suppliers/#{params[:id]}?return_url=/vshop/apply"
      @method = :put
    end
  end
end
