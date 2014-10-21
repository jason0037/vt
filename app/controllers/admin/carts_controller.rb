#encoding:utf-8
class Admin::CartsController < Admin::BaseController


  def show

  end
  def index
     @line_items = Ecstore::Cart.paginate(:page => params[:page], :per_page => 20).order("time DESC")




  end





end
