#encoding:utf-8
class Admin::OrdersController < Admin::BaseController
	before_filter :get_return_url, :only=>[:show,:detail,:pay,:delivery,:reship,:refund]
	skip_before_filter :verify_authenticity_token,:only=>[:batch]

  def destroy
    id = params[:id]
    @order_log = Ecstore::OrderLog.where(:rel_id=>id)
    @order_log.destroy_all
    @order_item = Ecstore::OrderItem.where(:order_id=>id)
    @order_item.destroy_all
    @order = Ecstore::Order.where(:order_id=>id)
    @order.destroy_all

    respond_to do |format|
      format.html { redirect_to admin_orders_url }
      format.json { head :no_content }
      format.js
    end
  end

	def index
		if params[:status].nil?
			@orders_nw = Ecstore::Order.order("createtime desc")
		elsif
			@orders_nw = Ecstore::Order.where(:status=>params[:status]).order("createtime desc")
		end

		if !params[:pay_status].nil?
			@orders_nw = @orders_nw.where(:pay_status=>params[:pay_status])
		end

		if !params[:ship_status].nil?
			@orders_nw = @orders_nw.where(:ship_status=>params[:ship_status])
    end

		@order_ids = @orders_nw.pluck(:order_id)
    role=current_admin.login_name.split( "_")[0]
    if (role=="sale")
      @orders = @orders_nw.where(:desktop_user_id=>current_admin.account_id)

    elsif (role=="vendor")
      vendor={'vendor_0001'=>66, 'vendor_0002'=>65,'vendor_ybpx'=>72,'vendor_xss'=>73,'vendor_xgy'=>63,'vendor_xj'=>64}
     # @orders = @orders_nw.joins(:order_items).where('sdb_b2c_order_items.goods_id in (3466,3467)')
        @orders = @orders_nw.joins(:order_items)
        .where("sdb_b2c_order_items.goods_id in (select goods_id from sdb_b2c_goods where supplier=#{vendor[current_admin.login_name]})")

    elsif (current_admin.login_name=="admin")
      @orders = @orders_nw
  else
  	  @orders = @orders_nw.where(:member_id=>"0")
  end
    @orders = @orders.includes(:user).paginate(:page=>params[:page],:per_page=>30)
		respond_to do |format|
			format.js
			format.html
		end
	end

	# def export
	# 	pp "---------------"
	# 	if params[:member][:select_all] == "1"
 #           @orders = Ecstore::Order.all  #找出所以数据
 #        else
 #           @orders = Ecstore::Order.find(:all,:conditions => ["order_id in (?)",params[:member][:select_val]])
 #        end
 #        pp @orders
 #        content = export_order(@orders)  #调用export方法
 #        send_data(content, :type => 'text/csv',:filename => "order_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv")
	# end

	# def export_order(orders)
	# 	field_name = ["订单号(order_id)","订单总额(final_amount)","付款状态(pay_status)","发货状态(ship_status)","下单时间(createtime)","支付方式(payment)","会员用户名(member_id)","订单状态(status)","收货地区(ship_area)","收货人(ship_name)","收货地址(ship_addr)","收货人电话(ship_tel)","收货人手机(ship_mobile)"]  #csv文件的头（标题）
	#     output = CSV.generate do |csv|
	#       csv << field_name
	#       content = []
	#       orders.each do |order|
	#       	content.push order.order_id
	#       	content.push order.final_amount
	#       	content.push order.pay_status_text
	#       	content.push order.ship_status_text
	#       	content.push Time.at(order.createtime).strftime("%Y-%m-%d %H:%M:%S")
	#       	content.push order.payment_name
	#       	content.push order.member_id
	#       	content.push order.order_status_text
	#       	content.push order.ship_area
	#       	content.push order.ship_name
	#       	content.push order.ship_addr
	#       	content.push order.ship_tel
	#       	content.push order.ship_mobile
	#       end
	#       csv << content
	#   	end
	# end

	def search
		if params[:s] && params[:s][:q].present?
			key = params[:s][:q]

			@orders = Ecstore::Order.includes(:user).where("order_id like ? or ship_name like ?","%#{key}%","%#{key}%").order("order_id desc")
			@order_ids = @orders.pluck(:order_id)
			@orders = @orders.paginate(:page=>params[:page],:per_page=>30)
			render :index
		else
			redirect_to admin_orders_url
		end
	end

	def batch
		act = params[:act]
              order_ids =  params[:order_ids] || []
              conditions = { :order_id=>order_ids }

              if act == "export"
              	orders = Ecstore::Order.where(conditions)
	              Ecstore::Order.export(orders)
	              return render :json=>{:csv=>"/tmp/orders.csv"}
              end

              if act == "tag"
              	tegs = params[:tegs] || {}

	              tegs.values.each  do |teg|
	                    	if teg[:technicals] == "checked"
	                    		Ecstore::Tagable.where(:rel_id=>order_ids,:tag_type=>"orders",:tag_id=>teg[:tag_id]).delete_all if teg[:state] == "none"
	                    	end

	                    	if teg[:technicals] == "uncheck"
	                    		order_ids.each do |order_id|
	                    			Ecstore::Tagable.create(:rel_id=>order_id,:tag_id=>teg[:tag_id],:tag_type=>"orders",:app_id=>"b2c")
	                    		end
	                    	end

	                    	if teg[:technicals] == "partcheck"
	                    		if teg[:state] == "all"
	                    			order_ids.each do |order_id|
				                     tagable = Ecstore::Tagable.where(:rel_id=>order_id,:tag_id=>teg[:tag_id],:tag_type=>"orders").first_or_initialize(:app_id=>"b2c")
				                     tagable.save
			                     end
	                    		end

	                    		if teg[:state] == "none"
	                    			Ecstore::Tagable.where(:rel_id=>order_ids,:tag_type=>"orders",:tag_id=>teg[:tag_id]).delete_all
	                    		end
	                    	end
	              end
              end


		if act == "get_same_tags"

			tag_ids = Ecstore::Tagable.where(:rel_id=>order_ids,:tag_type=>"orders").pluck(:tag_id)

			hash = Hash.new(0)
			tag_ids.each do |id|
			    if hash[id]
			        hash[id] += 1
			    else
			        hash[id] = 1
			    end
			end
			stat = Hash.new

			hash.each do |tag_id,count|
				if count>0 && count == order_ids.size
					stat[tag_id] = "all"
				end

				if count > 0 && count < order_ids.size
					stat[tag_id] = "part"
				end

				if count == 0
					stat[tag_id] = "none"
				end
			end
			return render :json=>stat
		end

              render :nothing=>true

	end

	def show
		@order =Ecstore::Order.find_by_order_id(params[:id])
	end

	def detail
		@order =Ecstore::Order.find_by_order_id(params[:id])
	end

	def pay
		@order =Ecstore::Order.find_by_order_id(params[:id])
	end

	def dopay
		@order =Ecstore::Order.find_by_order_id(params[:id])
		# return render :js=>"alert('获取订单失败');" unless @order

		if @order.pay_status == '1'
			return render :text=>"该订单已付款 !",:layout=>"admin"
		end

		@user = @order.user

		pay_app_id = params[:payment][:pay_app_id]
		params[:payment].merge! Ecstore::Payment::PAYMENTS[pay_app_id.to_sym]

		@payment = Ecstore::Payment.new params[:payment]  do |payment|
			payment.payment_id = Ecstore::Payment.generate_payment_id

			payment.status = 'ready'
			payment.pay_ver = '1.0'
			payment.paycost = 0

			payment.account = 'trade-V 跨境贸易直通车'
			payment.member_id = payment.op_id = @user.member_id
			payment.pay_account = @user.login_name
			payment.ip = request.remote_ip
			payment.t_begin = payment.t_confirm = Time.now.to_i
			payment.cur_money = params[:payment][:money].to_i
			payment.status = 'succ'
			payment.t_payed = Time.now.to_i

			payment.pay_bill = Ecstore::Bill.new do |bill|
				bill.rel_id  = @order.order_id
				bill.bill_type = "payments"
				bill.pay_object  = "order"
				bill.money = payment.money
			end
		end


		if @payment.save
			@order.update_attributes(:pay_status=>'1')

			Ecstore::OrderLog.new do |order_log|
				order_log.rel_id = @order.order_id
				order_log.op_id = current_admin.account_id
				order_log.op_name = current_admin.login_name
				order_log.alttime = @payment.t_payed
				order_log.behavior = 'payments'
				order_log.result = "SUCCESS"
				order_log.log_text = "订单支付成功！"
			end.save

			return_url =  params[:return_url] || admin_orders_url
			redirect_to "#{return_url}##{@order.order_id}"
		else
			render :pay
		end

	end

	def delivery


		@order = Ecstore::Order.find_by_order_id(params[:id])
		@delivery = Ecstore::Delivery.new do |delivery|
			delivery.ship_name = @order.ship_name
			delivery.ship_tel = @order.ship_tel
			delivery.ship_mobile = @order.ship_mobile
			delivery.ship_area = @order.ship_area
			delivery.ship_addr = @order.ship_addr
			delivery.ship_zip = @order.ship_zip
		end
	end

	def dodelivery
		@order = Ecstore::Order.find_by_order_id(params[:id])
		if @order.ship_status == '1'
			return render :text=>"该订单已发货 !",:layout=>"admin"
		end

		@delivery = Ecstore::Delivery.new params[:delivery] do |delivery|
			delivery.t_begin = Time.now.to_i
			delivery.status = "succ"
		end
		if @delivery.save
			begin
				tel  =@delivery.ship_mobile
				text = "您的订单#{@order.order_id}已发货,使用#{@delivery.logi_name},单号为#{@delivery.logi_no}.请注意查收! [TRADE-V]"
				Sms.send(tel,text)
			rescue Exception => e
			end
			return_url =  params[:return_url] || admin_orders_url
			redirect_to "#{return_url}##{@order.order_id}"
		else
			render :delivery
		end
	end


	def reship
		@order = Ecstore::Order.find_by_order_id(params[:id])
		@reship = Ecstore::Reship.new do |reship|
			reship.ship_name = @order.ship_name
			reship.ship_tel = @order.ship_tel
			reship.ship_mobile = @order.ship_mobile
			reship.ship_area = @order.ship_area
			reship.ship_addr = @order.ship_addr
			reship.ship_zip = @order.ship_zip
		end
	end

	def doreship
		@order = Ecstore::Order.find_by_order_id(params[:id])

		if ['0','4'].include?(@order.ship_status)
			return render :text=>"该订单#{order.ship_status_text}",:layout=>"admin"
		end

		@reship = Ecstore::Reship.new params[:reship] do |reship|
			reship.t_begin = Time.now.to_i
			reship.status = "succ"
		end
		if @reship.save

			return_url =  params[:return_url] || admin_orders_url
			redirect_to "#{return_url}##{@order.order_id}"
		else
			render :reship
		end
	end

	def refund
		@order =Ecstore::Order.find_by_order_id(params[:id])
	end

	def dorefund
		@order =Ecstore::Order.find_by_order_id(params[:id])

		if @order.pay_status == "5"
			return render :text=>"该订单已退款 !",:layout=>"admin"
		end

		@refund = Ecstore::Refund.new params[:refund]  do |refund|
			refund.refund_id = Ecstore::Refund.generate_refund_id
			refund.pay_ver = '1.0'
			refund.currency = "CNY"
			refund.paycost = 0
			refund.t_begin = refund.t_confirm = Time.now.to_i
			refund.cur_money = params[:refund][:money].to_i
			refund.status = 'succ'
			refund.t_payed = Time.now.to_i

			refund.bill = Ecstore::Bill.new do |bill|
				bill.rel_id  = @order.order_id
				bill.bill_type = "refunds"
				bill.pay_object  = "order"
				bill.money = refund.money
			end
		end


		if @refund.save
			#部分退款
			if @refund.money > 0 && @order.refunded_amount < @order.paid_amount
				@order.update_attributes(:pay_status=>'4')
				txt_key = "订单部分退款 ! "
			else
				@order.update_attributes(:pay_status=>'5')
				txt_key = "订单已退款 ! "
			end

			Ecstore::OrderLog.new do |order_log|
				order_log.rel_id = @order.order_id
				order_log.op_id = current_admin.account_id
				order_log.op_name = current_admin.login_name
				order_log.alttime = @refund.t_payed
				order_log.behavior = 'refunds'
				order_log.result = "SUCCESS"
				order_log.log_text = {:txt_key=>txt_key, :refund_id=>@refund.refund_id}.serialize
			end.save

			return_url =  params[:return_url] || admin_orders_url
			redirect_to "#{return_url}##{@order.order_id}"
		else
			render :refund
		end
	end

	def update
		@order =Ecstore::Order.find_by_order_id(params[:id])
		@order.update_attributes(params[:order])

		if @order.status == 'finish'
			order_log = Ecstore::OrderLog.new do |order_log|
	                order_log.rel_id = @order.order_id
	                order_log.op_id = current_admin.account_id
	                order_log.op_name = current_admin.login_name
	                order_log.alttime = Time.now.to_i
	                order_log.behavior = 'finish'
	                order_log.result = "SUCCESS"
	                order_log.log_text = "订单完成 !"
	             end.save
	      end

	      if @order.status == 'dead'
			order_log = Ecstore::OrderLog.new do |order_log|
	                order_log.rel_id = @order.order_id
	                order_log.op_id = current_admin.account_id
	                order_log.op_name = current_admin.login_name
	                order_log.alttime = Time.now.to_i
	                order_log.behavior = 'cancel'
	                order_log.result = "SUCCESS"
	                order_log.log_text = "取消订单 !"
	             end.save
	      end

		respond_to do |format|
			format.html
			format.js
		end
	end

	def comment
        @order = Ecstore::Order.find(params[:id])
    end

    def update_memo
    	@order = Ecstore::Order.find(params[:id])
    	@order.memo = params[:ecstore_order][:memo]
    	@order.save
    	order_log = Ecstore::OrderLog.new do |order_log|
	                order_log.rel_id = @order.order_id
	                order_log.op_id = current_admin.account_id
	                order_log.op_name = current_admin.login_name
	                order_log.alttime = Time.now.to_i
	                order_log.behavior = "memo"
	                order_log.result = "SUCCESS"
	                order_log.log_text = "memo info:#{params[:ecstore_order][:memo]}"
	             end.save
    	redirect_to admin_orders_url
    end


	# 购物单
	def print_order
		@title = "购物单"
		@order = Ecstore::Order.includes(:order_items).find_by_order_id(params[:id])
		render :layout=>"print"
	end

	# 配货单
	def print_preparer
		@title = "配货单"
		@order = Ecstore::Order.includes(:order_items).find_by_order_id(params[:id])
		render :layout=>"print"
	end

	private

	def get_return_url
		@return_url = request.env["HTTP_REFERER"] || admin_orders_url(:page=>params[:page])
	end

end
