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

  def apply
    if params[:id]
      @supplier  =  Ecstore::Supplier.find(params[:id])
      @action_url =  "/admin/suppliers/#{params[:id]}?return_url=/vshop/apply"
      @method = :put
    end
  end
end
