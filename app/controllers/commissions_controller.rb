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
      sql ="update mdk.sdb_wechat_followers set commission= (select sum(commission) from mdk.sdb_b2c_orders where recommend_user= '#{follower.openid}' group by recommend_user) where openid='#{follower.openid}'"
     # ActiveRecord::Base.connection.execute(sql)
    #end

    if @user
      @supplier = Ecstore::Supplier.where(:member_id=>@user.id,:status=>1).first
      if @supplier
        @total_member = Ecstore::Commission.where(:supplier_id=>@supplier.id).count()
        @commissions  = Ecstore::Commission.where(:supplier_id=>@supplier.id).paginate(:page => params[:page], :per_page => 20).order("account_id DESC")
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

  def register

  end

  def apply
    if params[:id]
      @supplier  =  Ecstore::Supplier.find(params[:id])
      @action_url =  "/admin/suppliers/#{params[:id]}?return_url=/vshop/apply"
      @method = :put
    end
  end
end
