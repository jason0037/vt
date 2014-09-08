#encoding:utf-8
class MobileController < ApplicationController
  #before_filter :find_user
  layout 'mobile_new'

  def show
    redirect_to '/vshop/78'

    @title = "贸威移动版"
    #@home = Ecstore::Home.last
    #if signed_in?
    #  redirect_to params[:return_url] if params[:return_url].present?
    #end
  end

  def blank
    @return_url = params[:return_url]
    render :layout=>nil
  end

  def topmenu
    render :layout=>nil
  end

end
