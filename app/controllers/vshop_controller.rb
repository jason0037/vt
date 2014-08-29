#encoding:utf-8
class VshopController < ApplicationController

  layout "vshop"

  def new
  	@account = Ecstore::Account.new
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

  def orders

    if @user
      if params[:status].nil?
        @orders_nw = Ecstore::Order.order("order_id desc")
      elsif
      @orders_nw = Ecstore::Order.where(:status=>params[:status]).order("order_id desc")
      end

      if !params[:pay_status].nil?
        @orders_nw = @orders_nw.where(:pay_status=>params[:pay_status])
      end

      if !params[:ship_status].nil?
        @orders_nw = @orders_nw.where(:ship_status=>params[:ship_status])
      end

      @order_ids = @orders_nw.pluck(:order_id)

      if ( @user.id== 2495)  #贸威

        @orders = @orders_nw
       else
              @orders =@orders_nw.where(:supplier_id=> @user.id)
      #  @orders = @orders_nw.where(:member_id=>"0")
      end
      @orders = @orders.includes(:user).paginate(:page=>params[:page],:per_page=>30)
      respond_to do |format|
        format.js
        format.html
      end

    else
      redirect_to '/vshop/login'
    end
  end

  def members
    if @user
      if @user.id== 2495 #贸威
        @total_member = Ecstore::Member.count()
        @members = Ecstore::Member.paginate(:page => params[:page], :per_page => 20).order("member_id DESC")
        @column_data = YAML.load(File.open(Rails.root.to_s+"/config/columns/member.yml"))
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

  def weixin
    if @user
      render 'weixin', :layout=>'vshop_wechat'
    else
      redirect_to '/vshop/login'
    end
  end

  def goods
    if @user
      @goods = Ecstore::Good.includes(:cat).includes(:brand)

      if @user.id!= 2495 #贸威
        @goods =@goods.where(:supplier_id=> @user.id)
      end

      @goods = @goods .paginate(:page=>params[:page],:per_page=>20,:order => 'uptime DESC')   #分页

      @count = @goods.count
    else
      redirect_to '/vshop/login'
    end
  end

  def article
    @article = Ecstore::Page.includes(:meta_seo).find(params[:id])
  end

  def create
  	now  = Time.now
	  @account = Ecstore::Account.new(params[:user]) do |ac|
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
      @by = params[:user][:by]
      value = params[:user][:value]
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
    @supplier=params[:id]
    @homepage = Ecstore::Home.where(:supplier_id=>@supplier).last
    render :layout=>"#{@homepage.supplier.url}"
  end

  def category
    @supplier=params[:id]
    @cat = params[:cat]
    @goods =  Ecstore::Good.where(:spplier_id=>@supplier,:cat=>@cat)
  end

end
