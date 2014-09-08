#encoding:utf-8
class CommissionsController < ApplicationController

  layout "vshop"

  #计算佣金,默认为当月
  def caculate

    #behavior='creates' 在正式使用阶段要改为 'payments'
    #平台佣金计算
    sql = "insert mdk.sdb_b2c_commissions (supplier_id,commission,`year_month`,ctype,orders_amount,rate,orders_num)
SELECT 78,sum(total_amount)*0.1,cast(FROM_UNIXTIME(alttime) as char(7)),1,sum(total_amount),0.1, count(*) FROM mdk.sdb_b2c_order_log as l
left join  mdk.sdb_b2c_orders as o on l.rel_id=o.order_id
where behavior='creates' group by left(FROM_UNIXTIME(alttime),7), supplier_id"

    #推广佣金计算
    sql="insert mdk.sdb_b2c_commissions (supplier_id,openid,commission,`year_month`,ctype,orders_amount,rate,orders_num)
SELECT 78, recommend_user,sum(total_amount)*0.01,cast(FROM_UNIXTIME(alttime) as char(7)),0,sum(total_amount),0.01, count(*) FROM mdk.sdb_b2c_order_log as l
left join  mdk.sdb_b2c_orders as o on l.rel_id=o.order_id
where behavior='creates' and length(recommend_user) is not null
group by left(FROM_UNIXTIME(alttime),7),recommend_user,supplier_id"

    yeah_month =params[:yearmonth]
   if yeah_month==nil
     yeah_month=Time.now.strftime('%Y-%m')
   end
    @commission = Ecstore::Commission.new
  end


  def index
    #更新佣金
    #@followers.each do |follower|
    #  sql ="update mdk.sdb_wechat_followers set commission= (select sum(commission) from mdk.sdb_b2c_orders where recommend_user= '#{follower.openid}' group by recommend_user) where openid='#{follower.openid}'"
     # ActiveRecord::Base.connection.execute(sql)
    #end

#推广佣金
    if @user
      @supplier = Ecstore::Supplier.where(:member_id=>@user.id,:status=>1).first
      if @supplier
        @total_member = Ecstore::Commission.where(:supplier_id=>@supplier.id,:ctype=>0).count()
        @commissions  = Ecstore::Commission.where(:supplier_id=>@supplier.id,:ctype=>0).paginate(:page => params[:page], :per_page => 20).order("id DESC")
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @commissions }
        end
      else
        redirect_to '/vshop/apply'
      end
    else
      redirect_to '/vshop/login'
    end
  end

  #平台佣金
  def platform

    if @user
      @supplier = Ecstore::Supplier.where(:member_id=>@user.id,:status=>1).first
      if @supplier
        @total_member = Ecstore::Commission.where(:supplier_id=>@supplier.id,:ctype=>1).count()
        @commissions  = Ecstore::Commission.where(:supplier_id=>@supplier.id,:ctype=>1).paginate(:page => params[:page], :per_page => 20).order("id DESC")
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @commissions }
        end
      else
        redirect_to '/vshop/apply'
      end
    else
      redirect_to '/vshop/login'
    end
  end

  def paid
    @commission = Ecstore::Commission.find(params[:id])
    @commission.update_attributes(:status => '1')
    redirect_to commissions_url
  end

  def bank_info

    supplier_id =@user.account.supplier_id
    if supplier_id==nil
      supplier_id =78
    end
    @supplier =   Ecstore::Supplier.find(supplier_id)

    render :layout=>@supplier.layout
  end

  def apply
    if params[:id]
      @supplier  =  Ecstore::Supplier.find(params[:id])
      @action_url =  "/admin/suppliers/#{params[:id]}?return_url=/vshop/apply"
      @method = :put
    end
  end

end
