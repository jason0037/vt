#encoding:utf-8
class Store::OrdersController < ApplicationController

  layout 'order'

  def mancoder_show
    supplier_id = @user.account.supplier_id
    if  @user

      if supplier_id == nil
        supplier_id=78
      end
      @supplier = Ecstore::Supplier.find(supplier_id)
      @orders =  @user.orders.order("createtime desc")

      if params["platform"]=="mobile"
        render :layout=>@supplier.layout
      end
    else
      return_url={:return_url => "/goods?platform=#{params["platform"]}&supplier_id=#{supplier_id}"}.to_query
      redirect_to "/auto_login?#{return_url}"
    end

    render :layout=>@supplier.layout

  end

  def share_order
    supplier_id =params[:supplier_id]
    @supplier = Ecstore::Supplier.find(supplier_id)
    @order =Ecstore::Order.find_by_order_id(params[:id])

    render :layout=>@supplier.layout
  end

  def out_inventory
    return_url =  request.env["HTTP_REFERER"]
    return_url =  member_goods_url if return_url.blank?

    @inventory = Ecstore::Inventory.where(:member_id=>current_account,:product_id=>params[:id]).first

    if @inventory.blank?
      #全部出库，删除记录
    else
      #部分出库，修改数量
      quantity =  @inventory.quantity - @inventory.quantity
      Ecstore::Inventory.where(:member_id=>current_account,:product_id=>params[:id]).update_all(:quantity=>quantity)
    end


    Ecstore::InventoryLog.new do |inventory_log|
      inventory_log.in_or_out =false
      inventory_log.member_id = @inventory.member_id
      inventory_log.goods_id =@inventory.goods_id
      inventory_log.product_id =@inventory.product_id
      inventory_log.price = @inventory.price
      inventory_log.quantity =@inventory.quantity
      inventory_log.name =@inventory.name
      inventory_log.bn = @inventory.bn
      inventory_log.barcode = @inventory.barcode
      inventory_log.createtime = Time.now.to_i
    end.save


    redirect_to return_url
  end

  def to_inventory
    return_url =  request.env["HTTP_REFERER"]
    return_url =  member_goods_url if return_url.blank?

    @order_item =  Ecstore::OrderItem.find(params[:id])

    @new_inventory = Ecstore::Inventory.where(:member_id=>current_account,:product_id=>@order_item.product_id).first

    @inventory =  Ecstore::Inventory.new

    if @new_inventory.blank?
      @inventory.member_id = @order_item.order.member_id
      @inventory.goods_id =@order_item.goods_id
      @inventory.product_id =@order_item.product_id
      @inventory.price = @order_item.price
      @inventory.quantity =@order_item.nums
      @inventory.name =@order_item.name
      @inventory.bn = @order_item.bn
      @inventory.barcode = @order_item.product.barcode
      @inventory.save
    else
      quantity =  @new_inventory.quantity + @order_item.nums
      Ecstore::Inventory.where(:member_id=>current_account,:product_id=>@order_item.product_id).update_all(:quantity=>quantity)
    end


    Ecstore::InventoryLog.new do |inventory_log|
      inventory_log.in_or_out =true
      inventory_log.order_item_id=@order_item.item_id
      inventory_log.order_id = @order_item.order_id
      inventory_log.member_id = @order_item.order.member_id
      inventory_log.goods_id =@order_item.goods_id
      inventory_log.product_id =@order_item.product_id
      inventory_log.price = @order_item.price
      inventory_log.quantity =@order_item.nums
      inventory_log.name =@order_item.name
      inventory_log.bn = @order_item.bn
      inventory_log.barcode = @order_item.product.barcode
      inventory_log.createtime = Time.now.to_i
    end.save


    @order_item.update_attribute :storaged, true
    redirect_to return_url
  end

  def index
    supplier_id = params[:supplier_id]
    if  @user
      supplier_id = @user.account.supplier_id
      if supplier_id == nil
        supplier_id=78
      end
      @supplier = Ecstore::Supplier.find(supplier_id)
      @orders =  @user.orders.order("createtime desc")

      if params["platform"]=="mobile"
        redirect_to "/orders/index_mobile?platform=mobile&supplier_id=#{supplier_id}"
      end
    else
      return_url={:return_url => "/goods?platform=#{params["platform"]}&supplier_id=#{supplier_id}"}.to_query
      redirect_to "/auto_login?#{return_url}&id=#{supplier_id}"
    end
  end

  def index_mobile             ###手机订单
    supplier_id = params[:supplier_id]
    if  @user
      if supplier_id == nil
        supplier_id=78
      end
      @supplier = Ecstore::Supplier.find(supplier_id)
      @orders =  @user.orders.order("createtime desc")

      if params["platform"]=="mobile"
        render :layout=>@supplier.layout
      end
    else
      return_url={:return_url => "/goods?platform=mobile&supplier_id=#{params[:supplier_id]}"}.to_query
      redirect_to "/auto_login?#{return_url}&id=#{params[:supplier_id]}"
    end
  end

  def show

    @order = Ecstore::Order.find_by_order_id(params[:id])
    if params["platform"]=="mobile"
      supplier_id=params[:supplier_id]
      if supplier_id==nil
        supplier_id=78
      end
      @supplier = Ecstore::Supplier.find(supplier_id)
      render :layout=>@supplier.layout

    end
  end


  def create

    platform = params[:platform]

    shop_id = params[:order][:shop_id]
  
    addr = Ecstore::MemberAddr.find_by_addr_id(params[:member_addr])
    supplier_id = @user.account.supplier_id

    hour = params[:hour]
    if params[:order][:ship_day]
       ship_day= params[:order][:ship_day]
       if ship_day!=("任意日期")

       ship_riqi=Time.parse(ship_day).to_i;       ###大渔饭店订餐日期
       end
     end
    return_url=params[:return_url]


    if supplier_id == nil
      supplier_id =78
    end

    unless supplier_id ==98
      ["name","area","addr","zip","tel","mobile"].each do |key,val|
        params[:order].merge!("ship_#{key}"=>addr.attributes[key])
      end
    end

    params[:order].merge!(:ip=>request.remote_ip, :member_id=>@user.member_id,:supplier_id=>supplier_id,:ship_day=>ship_riqi.to_s, :ship_time=>hour.to_s)

    #=====推广佣金计算=======
    recommend_user = session[:recommend_user]

    # if recommend_user==nil
    #   recommend_user= @user.login_name
    # end
    params[:order].merge!(:recommend_user=>recommend_user)
    #return render :text=>params[:order]
    #====================
    @order = Ecstore::Order.new params[:order]

    if recommend_user == nil
      @order.commission=0
    end
    #debug_line_item =''
    @line_items.each do |line_item|
      product = line_item.product
      good = line_item.good
      unless line_item.ref_id.nil?
          @tuan= Ecstore::GoodsPromotionRef.find(line_item.ref_id)

          count=@tuan.count+line_item.quantity
         @tuan.update_attributes(:count=>count)
      end
      if good.nil? || product.nil?
        next
      end




      @order.order_items << Ecstore::OrderItem.new do |order_item|
        order_item.product_id = product.product_id
        order_item.bn = product.bn
        order_item.name = product.name
        if cookies[:MLV] == "10"
          unless line_item.ref_id.nil?
            order_item.ref_id= line_item.ref_id
            if line_item.quantity.to_i>line_item.ecstore_goods_promotion_ref.persons.to_i-1
             order_item.price = line_item.ecstore_goods_promotion_ref.promotionsprice
            else
              order_item.price = product.bulk
            end
          else
            order_item.price = product.bulk
          end
       else

          unless line_item.ref_id.nil?
            order_item.ref_id= line_item.ref_id
            if  line_item.quantity.to_i>line_item.ecstore_goods_promotion_ref.persons.to_i-1
            order_item.price = line_item.ecstore_goods_promotion_ref.promotionsprice
             else
              order_item.price = product.price
             end
          else
            order_item.price = product.price
         end
        end
        order_item.goods_id = good.goods_id
        order_item.type_id = good.type_id
        order_item.nums = line_item.quantity.to_i
        order_item.item_type = "product"

         order_item.amount = order_item.price * order_item.nums


        order_item.share_for_promotion = order_item.amount* good.share
        order_item.share_for_sale = order_item.amount * good.share_for_sale
        order_item.share_for_shop = order_item.amount * good.share_for_shop

        product_attr = {}
        # product.spec_desc["spec_value"].each  do |spec_id,spec_value|
        # 	spec = Ecstore::Spec.find_by_spec_id(spec_id)
        # 	product_attr.merge!(spec_id=>{"label"=>spec.spec_name,"value"=>spec_value})
        # end
        order_item.addon = { :product_attr => product_attr }.serialize

        # @order.total_amount += order_item.calculate_amount
      end
      #     else
      #       debug_line_item +=line_item.id.to_s + '|'
      #    end
    end
    #if debug_line_item
    #  return render :text=>debug_line_item
    #end
    # ==== promotion gifts =====
    gifts = params[:gifts] || []
    gifts.each do |gift_id|
      gift = Ecstore::Product.find_by_product_id(gift_id)
      @order.order_items  << Ecstore::OrderItem.new do |order_item|
        order_item.product_id = gift_id
        order_item.goods_id = gift.goods_id
        order_item.type_id = gift.good.type_id if gift.good
        order_item.bn = gift.bn
        order_item.name = gift.name
        order_item.price = gift.price
        order_item.nums = 1
        order_item.item_type = 'gift'
        order_item.addon = nil
        order_item.amount = 0
      end
    end


    if @pmtable
      # ==== coupons======
      codes = params[:coupon].present? ? params[:coupon][:codes] : []
      coupons =  codes.collect do |code|
        Ecstore::NewCoupon.check_and_find_by_code(code)
      end.compact

      coupons.each do |coupon|
        @order.order_pmts << Ecstore::OrderPmt.new do |order_pmt|
          order_pmt.pmt_type = 'coupon'
          order_pmt.pmt_id = coupon.id
          order_pmt.pmt_amount = coupon.pmt_amount(@line_items)
          order_pmt.pmt_name = coupon.name
          order_pmt.pmt_desc = coupon.desc
          order_pmt.coupon_code = coupon.current_code
        end
      end
      # === goods promotions =====
      @goods_promotions = Ecstore::Promotion.matched_goods_promotions(@line_items)
      @goods_promotions.each do |promotion|
        @order.order_pmts << Ecstore::OrderPmt.new do |order_pmt|
          order_pmt.pmt_type = 'goods'
          order_pmt.pmt_id = promotion.id
          order_pmt.pmt_amount = promotion.goods_pmt_amount(@line_items)
          order_pmt.pmt_name = promotion.name
          order_pmt.pmt_desc = promotion.desc
        end
      end
      # ==== order promotions =====
      @order_promotions = Ecstore::Promotion.matched_promotions(@line_items)
      @order_promotions.each do |promotion|
        @order.order_pmts << Ecstore::OrderPmt.new do |order_pmt|
          order_pmt.pmt_type = 'order'
          order_pmt.pmt_id = promotion.id
          order_pmt.pmt_amount = promotion.pmt_amount(@line_items)
          order_pmt.pmt_name = promotion.name
          order_pmt.pmt_desc = promotion.desc
        end
      end
    end

    if @order.save

      @line_items.delete_all

      Ecstore::OrderLog.new do |order_log|
        order_log.rel_id = @order.order_id
        order_log.op_id = @order.member_id
        # if platform=="shop"
        #   order_log.op_name =Ecstore::Shop.find_by_shop_id(supplier_id).shop_name
        # else
        order_log.op_name = @user.login_name
        # end
        order_log.alttime = @order.createtime
        order_log.behavior = 'creates'
        order_log.result = "SUCCESS"
        order_log.log_text = "订单创建成功！"
      end.save
      if return_url.nil?
        if platform=="mobile"
          redirect_to "/orders/mobile_show?id=#{@order.order_id}&supplier_id=#{supplier_id}"
        elsif platform=="wuliu"
          redirect_to "/orders/wuliu_show?id=#{@order.order_id}&supplier_id=#{supplier_id}"
        elsif platform=="shop"
          redirect_to "/shop/visitors/order_show?id=#{@order.order_id}&shop_id=#{shop_id}"
        elsif
          redirect_to "#{order_path(@order)}?platform=#{platform}&supplier_id=#{supplier_id}"
        end
      else
        redirect_to return_url
      end
    else
      @addrs =  @user.member_addrs
      @def_addr = @addrs.where(:def_addr=>1).first || @addrs.first
      @coupons = @user.usable_coupons
      render :new
    end

  end

  def mobile_show
    supplier_id=params[:supplier_id]
    @order = Ecstore::Order.find_by_order_id(params[:id])

    if supplier_id==nil
      supplier_id=78
    end
    @supplier = Ecstore::Supplier.find(supplier_id)


    render :layout=>@supplier.layout
  end

  def new
    # @order = Ecstore::Order.new

    @addrs =  @user.member_addrs
    @def_addr = @addrs.where(:def_addr=>1).first || @addrs.first

    if @pmtable
      @order_promotions = Ecstore::Promotion.matched_promotions(@line_items)
      @goods_promotions = Ecstore::Promotion.matched_goods_promotions(@line_items)
      @coupons = @user.usable_coupons
    end


  end



  def new_mobile_addr

    supplier_id= @user.account.supplier_id
    if supplier_id==nil
      supplier_id=78
    end
    @supplier = Ecstore::Supplier.find(supplier_id)

    @addrs =  @user.member_addrs
    @def_addr = @addrs.where(:def_addr=>1).first || @addrs.first
    if params[:return_url]
      @return_url=params[:return_url]
     end
    render :layout=>@supplier.layout

  end

  def new_manco_addr    ###新增起点地址
      @manco_title="新增装货地址"
    @supplier = Ecstore::Supplier.find(params[:supplier_id])
    render :layout=>@supplier.layout
  end

  def addr_detail
    @manco_title="地址信息"
    @addr = Ecstore::MemberAddr.find(params[:id])
   supplier_id=params[:supplier_id]
    @supplier = Ecstore::Supplier.find(supplier_id)
    @method = :put



    render :layout=>@supplier.layout


  end

 def edit_addr
   @addr = Ecstore::MemberAddr.find(params[:id])
   if @addr.update_attributes(params[:addr])
      respond_to do |format|
       format.js
       format.html { redirect_to "/orders/new_mobile?platform=mobile" }
     end
   else
     render 'error.js' #, status: :unprocessable_entity
   end
 end


  def new_mobile
    session[:arrivals]=nil
    session[:zhuanghuo] =nil
    session[:xiehuo] =nil
    supplier_id= @user.account.supplier_id

    if supplier_id.nil?
      supplier_id=78
    end

    shop_id = params[:shop_id]
    if shop_id.nil?
      shop_id =' shop is null'
    end

   sql = "SELECT SUM(price*quantity) AS total,mdk.sdb_b2c_goods.supplier_id,SUM(freight)/count(*) AS freight FROM mdk.sdb_b2c_cart_objects
INNER JOIN mdk.sdb_b2c_goods ON SUBSTRING_INDEX(SUBSTRING_INDEX(mdk.sdb_b2c_cart_objects.obj_ident,'_',2),'_',-1) = mdk.sdb_b2c_goods.goods_id
WHERE mdk.sdb_b2c_cart_objects.member_id=#{@user.member_id} and shop_id is null
GROUP BY mdk.sdb_b2c_goods.supplier_id"
    @cart_total_by_supplier = ActiveRecord::Base.connection.execute(sql)
    @cart_freight = 0
    @favorable_terms = 0

    #免邮条件
    @cart_total_by_supplier.each(:as => :hash) do |row|
      if (row["total"]>=60 && row["supplier_id"]==97) || (row["total"]>=380 && row["supplier_id"]==77) || (row["total"]>=200 && row["supplier_id"]==127)#|| @cart_total==0.01 #测试商品
        @favorable_terms += row["freight"]
      end
      @cart_freight += row["freight"]
    end

    @cart_total_final = @cart_total+ @cart_freight - @favorable_terms
    @addrs =  @user.member_addrs
    if @addrs.size==0
      redirect_to "/orders/new_mobile_addr?supplier_id=#{supplier_id}&return_url=%2forders%2fnew_mobile?supplier_id%3d#{supplier_id}"
    else
      @def_addr = @addrs.where(:def_addr=>1).first || @addrs.first

      if @pmtable
        @order_promotions = Ecstore::Promotion.matched_promotions(@line_items)
        @goods_promotions = Ecstore::Promotion.matched_goods_promotions(@line_items)
        @coupons = @user.usable_coupons
      end
      @supplier = Ecstore::Supplier.find(supplier_id)
      render :layout=>@supplier.layout
    end
  end

  def departure    ##起点信息
    @manco_title="装货地址"
     @platform=params[:platform]
    @supplier=Ecstore::Supplier.find(params[:supplier_id])
    manco_weight =params[:manco_weight]
    @addrs =  @user.member_addrs
    @def_addrs = @addrs.where(:addr_type=>1) || @addrs.first


    render :layout=>@supplier.layout
  end

  def arrival  ###终点信息
    @manco_title="卸货地址"
    session[:arrivals]=params[:xiehuo]
    @platform=params[:platform]
    @supplier=Ecstore::Supplier.find(params[:supplier_id])
    @member_departure_id=  params[:member_departure_id]
    @addrs =  @user.member_addrs
    @addrss = @addrs.where(:addr_type=>0)
    if @platform=="door"||@platform=="self" ||@platform=="manco_local"||@platform=="mancoexpress"
    @action_url="/orders/manco_detail"
    elsif
      @action_url="new_manco  "
    end
    render :layout=>@supplier.layout
  end



  def new_tairyo
    if @pmtable
      @order_promotions = Ecstore::Promotion.matched_promotions(@line_items)
      @goods_promotions = Ecstore::Promotion.matched_goods_promotions(@line_items)
      @coupons = @user.usable_coupons
    end
    render :layout=>"tairyo_new"

  end

  def share
    wechat_user = params[:FromUserName]
    if @user
      wechat_user=@user.account.login_name
    end
    @supplier = Ecstore::Supplier.find(params[:supplier_id])
    @share=0
    @sharelast = 0
    if wechat_user
      @order_all = Ecstore::Order.where(:recommend_user=>wechat_user,:pay_status=>'1').select("sum(share_for_promotion) as share").group(:recommend_user).first
      if @order_all
        @share = @order_all.share.round(2)
        @order_last =Ecstore::Order.where(:recommend_user=>wechat_user,:pay_status=>'1').order("createtime desc").first
        if @order_last
          @sharelast = @order_last.commission
        end
      end
    end
       if @supplier.id==98
          @manco_title="我的佣金"
       end
    render :layout=>@supplier.layout

  end

  def tairyo_share
    wechat_user = params[:FromUserName]
    @share=0
    @sharelast = 0
    if wechat_user
      @order_all = Ecstore::Order.where(:recommend_user=>wechat_user).select("SUM(final_amount)*0.01 as share").group(:wechat_recommend).first
      #return render :text=>@order.final_amount
      if @order_all
        @share = @order_all.share.round(2)
        @order_last =Ecstore::Order.where(:recommend_user=>wechat_user).order("createtime desc").first
        if @order_last
          @sharelast = @order_last.final_amount*0.01.round(2)
        end
      end
    end

    render :layout=>"tairyo_new"
  end


  def shop_share
    @shop_title="我的收益"
    wechat_user = params[:FromUserName]
    @share=0
    @sharelast = 0
    if wechat_user
      @order_all = Ecstore::Order.where(:recommend_user=>wechat_user).select("SUM(final_amount)*0.01 as share").group(:wechat_recommend).first
      #return render :text=>@order.final_amount
      if @order_all
        @share = @order_all.share.round(2)
        @order_last =Ecstore::Order.where(:recommend_user=>wechat_user).order("createtime desc").first
        if @order_last
          @sharelast = @order_last.final_amount*0.01.round(2)
        end
      end
    end

    render :layout=>"shop"
  end



  def pay
    @order  = Ecstore::Order.find_by_order_id(params[:id])
    if @order &&@order.status == 'active' && @order.pay_status == '0'
      @order.update_attribute :payment, params[:order][:payment]
    else
      render :text=>"不存在的订单不能支付!"
    end
  end

  def detail
    @order  = Ecstore::Order.find_by_order_id(params[:id])
  end

  def check_coupon
    codes = params[:codes] || []

    now_code = codes.delete_at(0)
    now_coupon = Ecstore::NewCoupon.check_and_find_by_code(now_code)

    unless now_coupon
      return render :js=>"alert('该优惠券不存在')"
    end

    @coupons = codes.collect do |code|
      Ecstore::NewCoupon.check_and_find_by_code(code)
    end.compact #.sort { |x,y| y.priority <=> x.priority }

    if @coupons.size > 0 && @coupons.include?(now_coupon)
      render :js=>"alert('同一种的优惠券只能使用一次')"
      return
    end

    @coupons << now_coupon if now_coupon

    @coupons.sort! { |x,y| y.priority <=> x.priority }

    @useable = {}
    exclusive = false

    @coupons.each do |coupon|
      if coupon.test_condition(@line_items)
        if !exclusive
          @useable[coupon.current_code] =  true
        else
          @useable[coupon.current_code] =  false
        end

        exclusive = coupon.exclusive
      else
        @useable[coupon.current_code] =  false
      end
    end

    @coupon_amount = @coupons.select do |coupon|
      @useable[coupon.current_code]
    end.collect { |coupon| coupon.pmt_amount(@line_items) }.inject(:+)

  end

  def tairyo_order
    if @user
      @addrs =  @user.member_addrs

      @def_addr = @addrs.where(:def_addr=>1).first || @addrs.first
      login_name=@user.login_name
      sql="select * from sdb_pam_account where login_name=?",login_name  ;
      @account = Ecstore::Account.find_by_sql(sql)
      @suppliers=Ecstore::Supplier.find_by_sql("select * from sdb_imodec_suppliers where name='金芭浪'")
      render :layout => "tairyo_new"
    else
      redirect_to '/auto_login?id=99&platform=mobile&return_url=/tairyo_order'
    end
  end



  def destroyaddr

    @addr = Ecstore::MemberAddr.find(params[:addr_idsss])            ### 删除地址
    @addr.destroy

  end



  def manco_detail
    @manco_title="附加服务选项"
    @platform=params[:platform]
    @supplier=Ecstore::Supplier.find(params[:supplier_id])
    if (params[:member_departure_id])
      member_departure_id=params[:member_departure_id]

    else
      if session[:depar].nil?
        member_departure_id=session[:depars]  #有寄货地址 没收货地址的
      else
        member_departure_id=session[:depar]   #@addr.addr_id
      end

    end
    if(params[:member_arrival_id])
      member_arrival_id=params[:member_arrival_id]

    else
      member_arrival_id=session[:arri]
    end
    @departure_addr=Ecstore::MemberAddr.find_by_addr_id(member_departure_id)
    @arrival_addr=Ecstore::MemberAddr.find_by_addr_id(member_arrival_id)

   render :layout => @supplier.layout
  end

 def manco_card
   @manco_title="预付充值订单"
   @supplier = Ecstore::Supplier.find(params[:supplier_id])


   render :layout=>@supplier.layout

 end


  def new_manco
    @manco_title="物流订单详细"
       platform=params[:platform]

       bill=params[:bill]                   ###签单返回
       invoice=params[:invoice]             ######发票服务 1:运费发票 2: 服务费发票  3:自带发票
       warehouse=params[:warehouse]         ###进仓服务费 1: +150
       platform=params[:platform]
       @cart_totals = 0
       @bill=0
       @invoice=0
       @warehouse=0
        unless platform =="mancoblack_cart"
       @line_items.select{ |x| x.good.present? && x.product.present? }.each do |line_item|
          if line_item.good.cat_id==604
            @cart_totals=line_item.good.wholesale
          else
              sql = "SELECT price*quantity AS total,wholesale FROM mdk.sdb_b2c_cart_objects
INNER JOIN mdk.sdb_b2c_goods ON SUBSTRING_INDEX(SUBSTRING_INDEX(mdk.sdb_b2c_cart_objects.obj_ident,'_',2),'_',-1) = mdk.sdb_b2c_goods.goods_id
WHERE mdk.sdb_b2c_cart_objects.member_id=#{@user.member_id}"
              @cart_total_by_supplier = ActiveRecord::Base.connection.execute(sql)
               @cart_total_by_supplier.each(:as => :hash) do |row|
                   if (row["total"]<row["wholesale"])
                    @cart_totals+= row["wholesale"]
                  else
                    @cart_totals+= row["total"]
                  end
               end



          end
         end

                    end




       if bill=="1"
         @cart_totals=@cart_totals+5
         @bill+=1
       end
       if invoice=="1"
         @cart_totals=@cart_totals*1.11
         @invoice+=1
       elsif invoice=="2"
         @cart_totals=@cart_totals*1.08
         @invoice+=2
       elsif invoice=="3"
         @cart_totals=@cart_totals*1.01
         @invoice+=3
       end
       if warehouse=="1"
         @cart_totals=@cart_totals+150
         @warehouse+=1
       end

    if platform=="mancoexpress"|| platform=="door"|| platform=="self"  ||platform=="manco_local"
      @cart_total_final = @cart_totals
    else
      @cart_total_final = @cart_total
    end


    @supplier=Ecstore::Supplier.find(params[:supplier_id])
    if (params[:member_departure_id])
      member_departure_id=params[:member_departure_id]

    else
      if session[:depar].nil?
        member_departure_id=session[:depars]
      else
        member_departure_id=session[:depar]
      end

    end
    if(params[:member_arrival_id])
      member_arrival_id=params[:member_arrival_id]

    else
      member_arrival_id=session[:arri]
    end
    @departure_addr=Ecstore::MemberAddr.find_by_addr_id(member_departure_id)
    @arrival_addr=Ecstore::MemberAddr.find_by_addr_id(member_arrival_id)
    render :layout=>@supplier.layout
   end

  def wuliu_show
    supplier_id=params[:supplier_id]
    @order = Ecstore::Order.find_by_order_id(params[:id])
    @supplier = Ecstore::Supplier.find(supplier_id)


    render :layout=>@supplier.layout
  end



  def serach_order
    departure= params[:departure]
    arrival= params[:arrival]
    @un= Ecstore::Express.serachall(departure,arrival)
  end

  def goodblack
    @supplier=Ecstore::Supplier.find(params[:supplier_id])
    ship_id= params[:ship_id]
    @memberes=Ecstore::User.where(:member_id=>ship_id)
    render :layout => @supplier.layout

  end

  def mobile_show_order
    supplier_id=params[:supplier_id]
    if supplier_id.nil?
      supplier_id=78
    end
    @shop_id = params[:shop_id]
    @order =Ecstore::Order.find_by_order_id(params[:id])
    @delivery=Ecstore::Delivery.find_by_order_id(params[:id])
    @supplier  =  Ecstore::Supplier.find(supplier_id)

    render :layout=>@supplier.layout
  end

  def wuliu_show_order
    supplier_id=params[:supplier_id]
    @order =Ecstore::Order.find_by_order_id(params[:id])
    @delivery=Ecstore::Delivery.find_by_order_id(params[:id])
    @supplier  =  Ecstore::Supplier.find(supplier_id)
    render :layout=>@supplier.layout
  end

  def edit_manco_addr
    @bill=params[:bill]                   ###签单返回
    @invoice=params[:invoice]             ######发票服务 1:运费发票 2: 服务费发票  3:自带发票
    @warehouse=params[:warehouse]
       @way=params[:way]
       @departure_id=params[:departure_id]
       @arrival_id =params[:arrival_id]
        if @way =="departure"
          @addr=Ecstore::MemberAddr.find(@departure_id)
          @manco_title="修改装货地址"
        elsif  @way =="arrival"
            @addr=Ecstore::MemberAddr.find(@arrival_id)
            @manco_title="修改卸货地址"
        end
       @supplier=Ecstore::Supplier.find(params[:supplier_id])

       @action_url="xiugai_addr"
       @method="post"


      render :layout => @supplier.layout
  end




def xiugai_addr
  @bill=params[:bill]                   ###签单返回
  @invoice=params[:invoice]             ######发票服务 1:运费发票 2: 服务费发票  3:自带发票
  @warehouse=params[:warehouse]
  @way=params[:way]
  @departure_id=params[:departure_id]
  @arrival_id =params[:arrival_id]
  @addr = Ecstore::MemberAddr.find(params[:addr][:id])
  if @addr.update_attributes(params[:addr])
    respond_to do |format|
      format.js
      format.html { redirect_to "/orders/new_manco?supplier_id=98&bill=#{@bill}&invoice=#{@invoice}&warehouse=#{@warehouse}&member_departure_id=#{@departure_id}&member_arrival_id=#{@arrival_id}&way=#{@way} " }
    end
  else
    render 'error.js' #, status: :unprocessable_entity
  end
end



end
