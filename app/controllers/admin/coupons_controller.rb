#encoding:utf-8
module Admin
    class CouponsController < Admin::BaseController
      before_filter :require_permission!
      
      def index
      	if params[:search]&&params[:search][:key] && params[:search][:key].present?
      		key = params[:search][:key]
      		accounts = Ecstore::Account.where("login_name like ?","%#{key}%")
            @users = accounts.collect { |a| a.user }.paginate(params[:page] || 1)
      	else
      		@users = Ecstore::User.order("regtime DESC").paginate(:page=>params[:page],:per_page=>15)
      	end
      	current_time = Time.now.to_i
      	@coupons = Ecstore::Coupon.where(:cpns_status=>"1").select do |coupon|
      					rule = Ecstore::Rule.find_by_rule_id(coupon.rule_id)
      					if rule.from_time <= current_time && rule.to_time >= current_time
      						coupon
      					end
      				end
      end

      def create
          if params[:member_id] and params[:cpns_id]
              @user = Ecstore::User.find_by_member_id(params[:member_id])
              coupon = Ecstore::Coupon.find_by_cpns_id(params[:cpns_id])
              coupon_code = coupon.make_coupon_code
            #add coupon to user
            @memc = ::Ecstore::MemberCoupon.new do |mc|
                mc.memc_code = coupon_code
                mc.cpns_id =  coupon.cpns_id
                mc.member_id = @user.member_id
                mc.memc_source = coupon.cpns_type == "1" ? "b" : (coupon.cpns_type == "0" ? "a" : "c")
                mc.memc_enabled  = "true"
                mc.memc_gen_time = Time.now.to_i
                mc.disabled = "false"
                mc.memc_isvalid = "true"
            end
            @memc.transaction do
              @memc.save
              coupon.increment!(:cpns_gen_quantity) if @memc
              coupon_logger.info("[#{current_admin.login_name}][#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}][IP:#{request.remote_ip}]:添加优惠券#{coupon_code}(#{coupon.cpns_name}[#{coupon.cpns_id}])给用户[#{@user.account.login_name}]")
            end
            render "create"
        else
          render :js=>"alert('添加优惠券失败')"
        end
      end

      def destroy
        if params[:member_id] and params[:id] and params[:memc_code]
          user = Ecstore::User.find_by_member_id(params[:member_id])
          coupon = Ecstore::Coupon.find_by_cpns_id(params[:id])
          begin
            Ecstore::MemberCoupon.where(:cpns_id=>params[:id],
                      :member_id=>params[:member_id],
                      :memc_code=>params[:memc_code]).destroy_all #update_all({:memc_enabled=>'false',:disabled=>'true'})

            coupon_logger.info("[#{current_admin.login_name}][#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}][IP:#{request.remote_ip}]:删除用户[#{user.account.login_name}]优惠券#{params[:memc_code]}(#{coupon.cpns_name}[#{params[:cpns_id]}])")
            
            render "destroy"
          rescue
            render :js=>"alert('删除失败!')"
            return
          end
        else
          render :js=>"alert('删除失败!')"
        end
      end
    end
    
end
