#encoding:utf-8
class Store::GoodsController < ApplicationController
  layout 'standard'

  skip_before_filter :authorize_user!,:only=>[:price]
  before_filter :find_user, :except=>[:price]
  skip_before_filter :find_path_seo, :find_cart!, :only=>[:newest]
  before_filter :find_tags, :only=>[:cheuksgroup,:newest]

  def manco_cart
      @line_items.delete_all
      @manco_title="预付充值"
    @good = Ecstore::Good.find_by_name(params[:cart_name])
    @supplier=Ecstore::Supplier.find(params[:supplier_id])
    render layout: @supplier.layout
  end

  def show_goodblack
    @manco_title="货源小黑板"
     @supplier=Ecstore::Supplier.find_by_id(params[:supplier_id])
    @good=Ecstore::BlackGood.where(:id=>params[:id])
   render :layout =>@supplier.layout
  end

  def manco_express
    goods_id= params[:goods_id]     ##商品名称
    @manco_unit_price =params[:manco_unit_price]
    manco_weight=params[:manco_weight]

    @good=Ecstore::Good.find_by_goods_id(goods_id)

  end

     ###万家小黑板
  def mancoproduct
    @manco_title="车源小黑板"
     @supplier=Ecstore::Supplier.find(params[:supplier_id])
    @good = Ecstore::Good.includes(:specs,:spec_values,:cat).where(:bn=>params[:id]).first

    return render "not_find_good",:layout=>@supplier.layout unless @good

    @recommend_user = session[:recommend_user]

    if params[:wechatuser]
      @recommend_user=params[:wechatuser]
    end
    if @recommend_user
      member_id =-1
      if signed_in?
        member_id = @user.member_id
      end
      now  = Time.now.to_i
      Ecstore::RecommendLog.new do |rl|
        rl.wechat_id = @recommend_user
        rl.goods_id = @good.goods_id
        rl.member_id = member_id
        rl.terminal_info = request.env['HTTP_USER_AGENT']
        #   rl.remote_ip = request.remote_ip
        rl.access_time = now
      end.save
      session[:recommend_user]=@recommend_user
      session[:recommend_time] =now
    end

    tag_name = params[:tag]
    @tag = Ecstore::TagName.find_by_tag_name(tag_name)

    @cat = @good.cat

    @recommend_goods = []
    if @cat.goods.size >= 4
      @recommend_goods =  @cat.goods.where("goods_id <> ?", @good.goods_id).order("goods_id desc").limit(4)
    else
      @recommend_goods += @cat.goods.where("goods_id <> ?", @good.goods_id).limit(4).to_a
      @recommend_goods += @cat.parent_cat.all_goods.select{|good| good.goods_id != @good.goods_id }[0,4-@recommend_goods.size] if @cat.parent_cat && @recommend_goods.size < 4
      @recommend_goods.compact!
      if @cat.parent_cat.parent_cat && @recommend_goods.size < 4
        count = @recommend_goods.size
        @recommend_goods += @cat.parent_cat.parent_cat.all_goods.select{|good| good.goods_id != @good.goods_id }[0,4-count]
      end
    end
    render :layout => @supplier.layout

  end


 def mproduct

  @no_need_login = 1

    if params[:supplier_id]
      supplier_id  = params[:supplier_id]
    end
    if supplier_id.empty?
      supplier_id =78
    end

   if supplier_id=="78"
     set_locale
   end

  if params[:ref_id]
   @tuan=Ecstore::GoodsPromotionRef.where(:status=>"true",:ref_id=>params[:ref_id]).first
   end
   @good = Ecstore::Good.includes(:specs,:spec_values,:cat).where(:bn=>params[:id]).first

   return render "not_find_good",:layout=>"new_store" unless @good

   @recommend_user = session[:recommend_user]

   if @recommend_user==nil &&  params[:wechatuser]
    @recommend_user = params[:wechatuser]
   end
   if @recommend_user
     member_id =-1
     if signed_in?
       member_id = @user.member_id
     end
     now  = Time.now.to_i
      Ecstore::RecommendLog.new do |rl|
       rl.wechat_id = @recommend_user
       rl.goods_id = @good.goods_id
       rl.member_id = member_id
       rl.terminal_info = request.env['HTTP_USER_AGENT']
    #   rl.remote_ip = request.remote_ip
       rl.access_time = now
     end.save
    session[:recommend_user]=@recommend_user
    session[:recommend_time] =now
   end

   tag_name = params[:tag]
   @tag = Ecstore::TagName.find_by_tag_name(tag_name)

   @cat = @good.cat
   @recommend_goods = []
   if @cat.goods.size >= 4
     @recommend_goods =  @cat.goods.where("goods_id <> ?", @good.goods_id).order("goods_id desc").limit(4)
   else
     @recommend_goods += @cat.goods.where("goods_id <> ?", @good.goods_id).limit(4).to_a
     @recommend_goods += @cat.parent_cat.all_goods.select{|good| good.goods_id != @good.goods_id }[0,4-@recommend_goods.size] if @cat.parent_cat && @recommend_goods.size < 4
     @recommend_goods.compact!
     if @cat.parent_cat.parent_cat && @recommend_goods.size < 4
       count = @recommend_goods.size
       @recommend_goods += @cat.parent_cat.parent_cat.all_goods.select{|good| good.goods_id != @good.goods_id }[0,4-count]
     end
   end

   if supplier_id==nil
      if @user
        supplier_id= @user.account.supplier_id
      else
        supplier_id =@good.supplier_id
      end
   elsif supplier_id =="99"
     if params[:platform]=="tairyo"
       redirect_to "/tairyoall?supplier_id=#{supplier_id}&bn=#{params[:id]}"      ###金芭浪饭店订餐
    else
       redirect_to "/tproducts?supplier_id=#{supplier_id}&bn=#{params[:id]}"      ###金芭浪团购商品
      end
      else
      @supplier  =  Ecstore::Supplier.find(supplier_id)
          if params[:ref_id]
            render :layout=>"tuan"
          else
           render :layout=>@supplier.layout
         end
      end
 end


  def tairyoall
    supplier_id = params[:supplier_id]
    @good = Ecstore::Good.includes(:specs,:spec_values,:cat).where(:bn=>params[:id]).first
    @supplier  =  Ecstore::Supplier.find(supplier_id)
    render :layout=>@supplier.layout
  end
  def tairyo_tuan                                ###金芭浪团购商品
     bn= params[:bn]
    supplier_id = params[:supplier_id]
     @good = Ecstore::Good.includes(:specs,:spec_values,:cat).where(:bn=>bn).first

     return render "not_find_good",:layout=>"new_store" unless @good
    @supplier  =  Ecstore::Supplier.find(supplier_id)
    render :layout=>@supplier.layout

  end

  def show
    @wechat_user=params[:wechatuser]

    @good = Ecstore::Good.includes(:specs,:spec_values,:cat).where(:bn=>params[:id]).first

    return render "not_find_good",:layout=>"new_store" unless @good
    tag_name = params[:tag]
    @tag = Ecstore::TagName.find_by_tag_name(tag_name)

    @cat = @good.cat

    @recommend_goods = []
    if @cat.goods.size >= 4
      @recommend_goods =  @cat.goods.where("goods_id <> ?", @good.goods_id).order("goods_id desc").limit(4)
    else
      @recommend_goods += @cat.goods.where("goods_id <> ?", @good.goods_id).limit(4).to_a
      @recommend_goods += @cat.parent_cat.all_goods.select{|good| good.goods_id != @good.goods_id }[0,4-@recommend_goods.size] if @cat.parent_cat && @recommend_goods.size < 4
      @recommend_goods.compact!
      if @cat.parent_cat.parent_cat && @recommend_goods.size < 4
        count = @recommend_goods.size
        @recommend_goods += @cat.parent_cat.parent_cat.all_goods.select{|good| good.goods_id != @good.goods_id }[0,4-count]
      end
    end

    respond_to do |format|
      format.html { render :layout=>"new_store" }
      format.mobile { render :layout=>"msite" }
    end
  end

 def tairyo_show
   tag_name  = params[:tag]
   @tag = Ecstore::Teg.find_by_tag_name(tag_name)
   if @tag
     order = params[:order]
     order_string = "goods_id desc"
     if order.present?
       order_string = order.split("-").join(" ")
     end
     @goods = @tag.goods.order(order_string).paginate(:page=>params[:page], :per_page=>18)
   else
     redirect_to  newest_goods_url
   end
 end
  def index
      tag_name  = params[:tag]
      @tag = Ecstore::Teg.find_by_tag_name(tag_name)
       if @tag
              order = params[:order]
              order_string = "goods_id desc"
              if order.present?
                order_string = order.split("-").join(" ")
              end
              @goods = @tag.goods.order(order_string).paginate(:page=>params[:page], :per_page=>18)
       else
            redirect_to  newest_goods_url
       end
  end

  def newin
      @line_items =  @user.line_items if @user
      @tag = Ecstore::TagName.where('tag_name rlike ?','z[0-9]{4}').last
      if @tag
          if params[:page].nil? || params[:page].to_i <= 1
              @goods = @tag.goods.paginate(:page=>1, :per_page=>10,:order=>"uptime desc").to_a
              # render "index"
              respond_to do |format|
                format.mobile  { render(:layout => "layouts/store", :action => "index") }
                format.html { render(:layout => "layouts/store", :action => "index") }
              end

          else
              @goods = @tag.goods.paginate(:page=>params[:page], :per_page=>10,:order=>"uptime desc").to_a
              render "scroll_loading"
          end
      end

  end

  def newest
      @tag = @tags.first
      if @tag
          order = params[:order]
          order = params[:order]
          order_string = "goods_id desc"
          if order.present?
            order_string = order.split("-").join(" ")
          end
          @goods = @tag.goods.order(order_string).paginate(:page=>params[:page], :per_page=>18)
      end
      respond_to do |format|
          format.html { render "index" }
      end
  end

  def suits
      @line_items =  @user.line_items if @user
      @goods = Ecstore::Good.suits.paginate(:page=>1, :per_page=>10,:order=>"uptime desc")

      respond_to do |format|
        format.html { render :layout=>"standard" }
        format.js
      end
  end

  def more_suits
      @goods = Ecstore::Good.suits.paginate(:page=>params[:page], :per_page=>10,:order=>"uptime desc")
      render :layout=>nil
  end


  def more
    @tags = Ecstore::TagName.where('tag_name rlike ?','z[0-9]{4}').order("tag_id desc").select { |t| t&&t.tag_ext&&!t.tag_ext.disabled }.paginate(params[:page]||1,9)
    render :layout=>'standard'
  end



  def fav
      @good = Ecstore::Good.find(params[:id])
      @fav =  Ecstore::Favorite.new do |fav|
          fav.goods_id = params[:id]
          fav.member_id = @user.member_id
          fav.status = 'ready'
          fav.create_time = Time.now.to_i
          fav.disabled =  'false'
          fav.type = 'fav'
          fav.object_type = "goods"
      end
      @fav.save
      render "fav"
  end

  def unfav
      @good = Ecstore::Good.find(params[:id])
      Ecstore::Favorite.where(:member_id=>@user.member_id,
                                             :goods_id=>params[:id]).delete_all
      render "unfav"
  end

  def price
      @good = Ecstore::Good.includes(:products,:good_type_specs).find(params[:id])

      return render(:nothing=>true) unless request.xhr?
      spec_type_count = @good.good_type_specs.blank? ? 1  : @good.good_type_specs.size
      return render(:nothing=>true)  if params[:spec_values].size != spec_type_count

      @product  =  @good.products.select do |p|
        p.good_specs.pluck(:spec_value_id).map{ |x| x.to_s }.sort == params[:spec_values].sort || p.spec_desc["spec_value_id"].values.map{ |x| x.to_s }.sort == params[:spec_values].sort
      end.first

      render :json=>{ :price=>@product.price,:store=>@product.p_store }
  end


  private
    def more_arrivals
        except_tag = ''
        except_tag = params[:tag] if params[:tag].present?
        except_tag = Ecstore::TagName.where('tag_name rlike ?','z[0-9]{4}').last.tag_name if action_name == "newest"

        @tags ||= Ecstore::TagName.where('tag_name rlike ? and tag_name <> ?','z[0-9]{4}',except_tag).order("tag_id desc").limit(6)

    end

    def more_products
        except_tag = ''
        except_tag = params[:tag] if params[:tag].present?
        except_tag = Ecstore::TagName.where('tag_name rlike ?','z[0-9]{4}').last.tag_name if action_name == "newest"

        @tags ||= Ecstore::TagName.where('tag_name rlike ? and tag_name <> ?','z[0-9]{4}',except_tag).order("tag_id desc")
    end

    def find_search_key
        config = Ecstore::Config.find_by_key('search_key')
        @search_key =  config.value  if config
    end

    def find_tags
        @tags =  Ecstore::Teg.includes(:tag_ext).where('tag_name rlike ?','z[0-9]{4}').order("tag_id desc").limit(20)
    end



end
