#encoding:utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include Breadcrumb

  

  layout "survey"

  # before_filter :authorize_user!
  before_filter :adjust_format_for_mobile
  before_filter :find_user,:find_session_id,:find_cart!
  before_filter :find_path_seo
  before_filter :set_locale




  require "pp"

  def set_locale
    if params[:id] =="78"|| params[:supplier_id]=="78"
     session[:locale] = params[:locale] if params[:locale]
     I18n.locale = session[:locale] || I18n.default_locale
     locale_path = "#{LOCALES_DIRECTORY}#{I18n.locale}.yml"
    unless I18n.load_path.include? locale_path
      I18n.load_path << locale_path
      I18n.backend.send(:init_translations)
    end
    end
  rescue Exception => err
    logger.error err
    flash.now[:notice] = "#{I18n.locale} error"
    I18n.load_path -= [locale_path]
    I18n.locale = session[:locale] = I18n.default_locale
  end


  private 

    def adjust_format_for_mobile
        request.format = :mobile if params[:agent] == "mobile"
    end

    def find_session_id
       cookies[:m_id] = request.session_options[:id] unless cookies[:m_id].present?
       @m_id = cookies[:m_id]
    end

    def find_cart!
      shop_id = session[:shop_id]
      session[:shop_id]=nil
      if signed_in?

        if (shop_id.nil?)
          @line_items = Ecstore::Cart.where(:member_id=>current_account.account_id,:shop_id=>nil).order("supplier_id")
        else
          @line_items = Ecstore::Cart.where(:member_id=>current_account.account_id,:shop_id=>shop_id)
        end
      else
        member_ident = @m_id
        @line_items = Ecstore::Cart.where(:member_ident=>member_ident)
      end

      @cart_total_quantity = @line_items.inject(0){ |t,l| t+=l.quantity }.to_i || 0

        @cart_total1=0  ###团购
        @cart_total2=0
        @cart_total=0

      if cookies[:MLV] == "10"
        @line_items.each do |li|
          unless li.ref_id.nil?
            if li.quantity.to_i>li.ecstore_goods_promotion_ref.persons.to_i-1
              @cart_total1 += li.ecstore_goods_promotion_ref.promotionsprice*li.quantity
            else
               @cart_total2 += li.product.price*li.quantity
            end
          else
            @cart_total2 += li.product.bulk*li.quantity
            #    @line_items.select{|x| x.product.present? }.collect{ |x| (x.product.bulk*x.quantity) }.inject(:+) || 0
          end
        end
      else
        @line_items.each do |li|
          unless li.ref_id.nil?
            if li.quantity.to_i>li.ecstore_goods_promotion_ref.persons.to_i-1
              @cart_total1= @cart_total1+li.ecstore_goods_promotion_ref.promotionsprice*li.quantity
            else
               @cart_total2 =  @cart_total2+ li.product.price*li.quantity
            end
          else
              @cart_total2 =  @cart_total2+ li.product.price*li.quantity
              # @line_items.select{|x| x.product.present? }.collect{ |x| (x.product.price*x.quantity) }.inject(:+) || 0
          end   
        end
      end
      @cart_total = @cart_total1 + @cart_total2

      #@pmtable = @line_items.select { |line_item| line_item.good.is_suit? }.size == 0
     
    end



    def find_user
      # if Rails.env == "development"
      #   return  @user = Ecstore::User.find_by_member_id(217)
      # end

      unless signed_in?
         nologin_times = cookies[:nologin_times] || 0
         cookies[:nologin_times] = nologin_times.to_i + 1
      end


      return  true if (params[:token].present? || params[:agent] == "mobile") && !signed_in?
      if signed_in?
        @user = current_account.user
      else
          # return (render :js=>"window.location.href='#{site_path}'") if request.xhr?
      	   # redirect_to (site_path)
      end
    end




    # find categories
    def require_top_cats
      @top_cats = Ecstore::Category.where(:parent_id=>0).where('sell=true or future=true or agent=true').where("cat_name not in (?)",['时装周预售','VIP卡']).order("p_order asc")
    end

    def find_path_seo

      return  unless request.method == "GET"

      path  = request.env["PATH_INFO"]

      metas = Ecstore::MetaSeo.path_metas.where(:path=>path).select do |meta|
          if meta.params.blank?
              true
          else
              meta.params.select do |key, val|
                 reg = Regexp.new("^#{val}$")
                 params[key] =~ reg
              end.size == meta.params.size
          end
      end

      @meta_seo  = metas.first

    end
  def check_token
    if session[:authenticity_token] == params[:authenticity_token]
      session[:authenticity_token] = nil
      session.update
      return true
    end
    false
  end
end
