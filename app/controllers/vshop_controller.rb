#encoding:utf-8
require  'modec_pay'
class VshopController < ApplicationController
  skip_before_filter :set_locale

  layout "vshop"


  def new
    @account = Ecstore::Account.new
  end

  def login

  end

  def register

  end

  def user

    set_locale

    if @user

      @supplier =Ecstore::Supplier.find(params[:id])
      if @supplier.id==98
         @manco_title="个人中心"
      end
      render :layout=>@supplier.layout
    else
      redirect_to "/auto_login?id=#{params[:id]}&platform=mobile&return_url=/vshop/#{params[:id]}/user?id=#{params[:id]}"
    end
  end

  def apply
    if params[:id]
      @supplier  =  Ecstore::Supplier.find(params[:id])
      @action_url =  "/admin/suppliers/#{params[:id]}?return_url=/vshop/apply"
      @method = :put
    end
  end

  #get /vshop/orders
  def orders

    if @user

      @orders_nw =Ecstore::Order.where(:supplier_id=> @user.account.supplier_id).order("order_id desc")

      if params[:status].nil?
        @orders_nw = @orders_nw
      elsif
      @orders_nw = @orders_nw.where(:status=>params[:status])
      end

      if !params[:pay_status].nil?
        @orders_nw = @orders_nw.where(:pay_status=>params[:pay_status])
      end

      if !params[:ship_status].nil?
        @orders_nw = @orders_nw.where(:ship_status=>params[:ship_status])
      end

      @order_ids = @orders_nw.pluck(:order_id)


      @orders = @orders_nw.includes(:user).paginate(:page=>params[:page],:per_page=>30)

      respond_to do |format|
        format.js
        format.html
      end

    else
      redirect_to '/vshop/login'
    end
  end

  #get /vshop/members
  def members
    if @user
      @supplier = Ecstore::Supplier.where(:member_id=>@user.id,:status=>1).first
      if @supplier
        @total_member = Ecstore::Account.where(:supplier_id=>@supplier.id).count()
        @accounts = Ecstore::Account.where(:supplier_id=>@supplier.id).paginate(:page => params[:page], :per_page => 20).order("account_id DESC")
        #@column_data = YAML.load(File.open(Rails.root.to_s+"/config/columns/member.yml"))
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @members }
        end
      else
        redirect_to '/vshop/apply'
      end
    else
      redirect_to '/vshop/login'
    end
  end

  #get /vshop/weixin
  def weixin
    if @user
      @supplier = Ecstore::Supplier.where(:member_id=>@user.account.id).first
      @action = "/admin/suppliers/#{@supplier.id}?return_url=/vshop/weixn"
      render  :layout=>'vshop_wechat'
    else
      redirect_to '/vshop/login'
    end
  end

  #get /vshop/goods
  def goods
    if @user

      @goods = Ecstore::Good.includes(:cat).includes(:brand)
      @supplier =Ecstore::Supplier.find_by_member_id(@user.id)
      if @user.id!= 2495 #贸威
        @supplier =Ecstore::Supplier.find_by_member_id(@user.id)
        @goods = @goods.where(:supplier_id=>@supplier.id)
      end
      if @supplier.id ==Ecstore::Supplier.find_by_name("万家物流").id
        if params[:name]=="货源"
          @goodes=Ecstore::BlackGood.paginate :page=>params[:page],        ###分页语句
                                              :per_page =>20,              ###当前只显示一条
                                              :conditions => ["cat_id=571"]
        else
          cat_id=params[:cat_id]
          if cat_id.nil?
            cat_id=570
          end
          @goods = @goods.paginate(:page=>params[:page],:per_page=>20,:order => 'uptime DESC',:conditions => ["cat_id=#{cat_id}"])
        end
      else
        @goods = @goods.paginate(:page=>params[:page],:per_page=>20,:order => 'uptime DESC')   #分页

      end

      @count = @goods.count

    else
      redirect_to '/vshop/login'
    end
  end

  def black_good_destory          ##万家物流货源信息删除
    @black_good =  Ecstore::BlackGood.find(params[:id])
    @black_good.destroy
    redirect_to "/vshop/goods"
  end

  def destory
    @good=Ecstore::Good.find(params[:id])
    @good.destroy
    redirect_to "/vshop/goods"

  end



  def article
    @article = Ecstore::Page.includes(:meta_seo).find(params[:id])
  end

  def create
    now  = Time.now
    @account = Ecstore::Account.new(params[:users]) do |ac|
      ac.account_type ="member"
      ac.createtime = now.to_i
      ac.user.member_lv_id = 1
      ac.user.cur = "CNY"
      ac.user.reg_ip = request.remote_ip
      ac.user.regtime = now.to_i
    end

    if @account.save
      sign_in(@account)
      @return_url=params[:return_url]
      render "create"
    else
      render "error"
    end
  end

  def search
    @title = "找回密码"
    @by = params[:users][:by]
    value = params[:users][:value]
    col =  case @by
             when 'mobile' then '手机号码'
             when 'email' then '邮箱'
             when 'login_name' then '用户名'
             else '用户名'
           end
    if value.present?
      @user = Ecstore::User.joins(:account).where("#{@by} = ?",value).first
      if @user
        render "find_by_#{@by}"
      else
        redirect_to forgot_password_users_url(:by=>@by), :notice=> "您输入的#{col}不存在"
      end
    else
      redirect_to forgot_password_users_url(:by=>@by), :notice=> "请输入#{col}"
    end
  end

  #get /vhsop/id 显示微店铺首页
  def show

    if params[:id]=="78"
      set_locale
    end


    @supplier_id=params[:id]
    @homepage = Ecstore::Home.where(:supplier_id=>@supplier_id).last
    @supplier = Ecstore::Supplier.find(@supplier_id)
    @good=Ecstore::Good.where(:supplier_id=>@supplier_id)


    render :layout=>@supplier.layout
  end

  #get /vhsop/id/category?cat=
  def category

    @supplier_id=params[:id]
    @cat = params[:cat]
    @goods =  Ecstore::Good.where(:supplier_id=>@supplier_id,:cat_id=>@cat)
    @supplier = Ecstore::Supplier.find(@supplier_id)

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
        #  rl.goods_id = @good.goods_id
        rl.member_id = member_id
        rl.terminal_info = request.env['HTTP_USER_AGENT']
        #   rl.remote_ip = request.remote_ip
        rl.access_time = now
      end.save
      session[:recommend_user]=@recommend_user
      session[:recommend_time] =now
    end

    render :layout=>"#{@supplier.layout}"
  end

  #get /vhsop/id/payments

  def payments

    supplier_id = params[:supplier_id]
    shop_id = params[:shop_id]

    if supplier_id.size==0
      supplier_id=78
    end

    #获取不同供应商支付接口参数
    supplier_pay_id = params[:id] 
    @supplier_pay  = Ecstore::Supplier.find(supplier_pay_id)    

    @payment = Ecstore::Payment.find(params[:payment_id])
    if @payment && @payment.status == 'ready'
      adapter = @payment.pay_app_id
      order_id = @payment.pay_bill.rel_id
      @modec_pay = ModecPay.new adapter do |pay|
        pay.return_url = "#{site}/payments/#{@payment.payment_id}/#{adapter}/callback"
        pay.notify_url = "#{site}/vshop/#{supplier_pay_id}/paynotifyurl?payment_id=#{@payment.payment_id}&supplier_id=#{supplier_id}&shop_id=#{shop_id}"
       
        pay.pay_id = @payment.payment_id
        pay.pay_amount = @payment.cur_money.to_f
        pay.pay_time = Time.now
        pay.subject = "#{@supplier_pay.name}订单(#{order_id})"
        pay.installment = @payment.pay_bill.order.installment if @payment.pay_bill.order
       
        pay.openid = @user.account.login_name
        pay.spbill_create_ip = request.remote_ip
        pay.supplier_id = supplier_pay_id
        pay.appid = @supplier_pay.weixin_appid
        pay.mch_id = @supplier_pay.mch_id
        pay.partner_key = @supplier_pay.partner_key
        pay.partnerid = @supplier_pay.partnerid
      end
    

      @supplier = Ecstore::Supplier.find(supplier_id) 

      if shop_id
        layout = "shop"
      else
        layout = @supplier.layout
      end

      render :inline=>@modec_pay.html_form_wxpay, :layout=>layout

      Ecstore::PaymentLog.new do |log|
        log.payment_id = @payment.payment_id
        log.order_id = order_id
        log.pay_name = adapter
        log.request_ip = request.remote_ip
        log.request_params = @modec_pay.fields.to_json
        log.requested_at = Time.now
      end.save
    else
      flash[:msg] = '不能支付,请查看订单状态'
    end
  end

  def paynotifyurl
    #========================
    if params[:temp]=="solution"

      @payment = Ecstore::Payment.find(params[:payment_id])
      return redirect_to detail_order_path(@payment.pay_bill.order) if @payment&&@payment.paid?

      @order = @payment.pay_bill.order
      @order.update_attributes(:pay_status=>'1')

      @order.order_items.each do |order_item|
          if  order_item.good.cat_id==600
              member_id=@order.member_id
              @member = Ecstore::Member.find(member_id)
              @users = Ecstore::User.find(member_id)
               if @member.advance
               advance=@member.advance+order_item.good.mktprice
               else
                 advance=order_item.good.mktprice
               end

              advances =  @users.member_advances.order("log_id asc").last
              if advances
                shop_advance = advances.shop_advance
              else
                shop_advance =@member.advance
              end
              shop_advance += order_item.good.mktprice
              @member.update_attribute(:advance,advance)
              Ecstore::MemberAdvance.create(:member_id=>member_id,
                                            :money=>order_item.good.mktprice,
                                            :message=>"万家预充值:#{order_item.good.name}",
                                            :mtime=>Time.now.to_i,
                                            :memo=>"用户本人操作",
                                            :order_id=>@order.order_id,
                                            :import_money=>order_item.good.mktprice,
                                            :explode_money=>0,
                                            :member_advance=>(advance),
                                            :shop_advance=>shop_advance,
                                            :disabled=>'false')
          end
      end


      return redirect_to "/orders/mobile_show_order?id=#{@order.order_id}&supplier_id=#{params[:id]}"
    end
    #========================

    ModecPay.logger.info "[#{Time.now}][#{request.remote_ip}] #{request.request_method} \"#{request.fullpath}\" params : #{ params.to_s }"

    @payment = Ecstore::Payment.find(params.delete(:payment_id))

    return render :nothing=>true, :status=>:forbidden if @payment.paid?

    adapter  = 'wxpay'

    @order = @payment.pay_bill.order
    @user = @payment.user

    result = ModecPay.verify_notify(adapter,params,{:ip=>request.remote_ip })

    @payment.payment_log.update_attributes({:notify_ip=>request.remote_ip,
                                            :notify_params=> params.to_json,
                                            :notified_at=>Time.now,
                                            :result=>result.to_json}) if @payment.payment_log

    if result.is_a?(Hash) && result.present?
      response = result.delete(:response)
      if result.delete(:payment_id) == @payment.payment_id.to_s && !@payment.paid?
        @payment.update_attributes(result)
        @order.update_attributes(:pay_status=>'1')
        Ecstore::OrderLog.new do |order_log|
          order_log.rel_id = @order.order_id
          order_log.op_id = @user.member_id
          order_log.op_name = @user.login_name
          order_log.alttime = @payment.t_payed
          order_log.behavior = 'payments'
          order_log.result = "SUCCESS"
          order_log.log_text = "订单支付成功！"
        end.save
      end
    else
      response =  result
    end

    render :text=>response
  end

  def notice
    @supplier=Ecstore::Supplier.find(params[:supplier_id])

    render :layout => @supplier.layout

  end

end
