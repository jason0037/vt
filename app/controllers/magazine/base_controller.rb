class Magazine::BaseController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  layout 'magazine'
  # before_filter :authorize_user!


  before_filter :find_user
  before_filter :find_session_id, :find_cart!

  private

  def find_user
  	@user = current_account.user if signed_in?
  end

  def find_session_id
       cookies[:m_id] = request.session_options[:id] unless cookies[:m_id].present?
       @m_id = cookies[:m_id]
  end

  def find_cart!
            if signed_in?
              @line_items = Ecstore::Cart.where(:member_id=>current_account.account_id)
            else
              member_ident = @m_id
              @line_items = Ecstore::Cart.where(:member_ident=>member_ident)
            end
            @cart_total_quantity = @line_items.inject(0){ |t,l| t+=l.quantity }.to_i || 0

            @cart_total = @line_items.select{|x| x.product.present? }.collect{ |x| (x.product.price*x.quantity).to_i }.inject(:+) || 0
    end

end