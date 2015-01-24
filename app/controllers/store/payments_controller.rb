#encoding:utf-8
require  'modec_pay'
class Store::PaymentsController < ApplicationController
	layout 'order'

	skip_before_filter :verify_authenticity_token,:only=>[:callback,:notify]
 
	def create
		rel_id = params[:order_id]
		@order  = Ecstore::Order.find_by_order_id(rel_id)
		installment = params[:payment].delete(:installment) || 1
		part_pay = params[:payment].delete(:part_pay) || 0

		pay_app_id = params[:payment][:pay_app_id]

		if part_pay == 0 && @order.part_pay?
			@user.update_column :advance, @order.part_pay
			@user.update_column :advance_freeze, @user.advance_freeze - @order.part_pay
		end

		#  update order payment
		@order.update_attributes :payment=>pay_app_id,:last_modified=>Time.now.to_i,:installment=>installment,:part_pay=>part_pay if pay_app_id.to_s != @order.payment.to_s

		params[:payment].merge! Ecstore::Payment::PAYMENTS[pay_app_id.to_sym]

		@payment = Ecstore::Payment.new params[:payment]  do |payment|
			payment.payment_id = Ecstore::Payment.generate_payment_id
			payment.status = 'ready'
			payment.pay_ver = '1.0'
			payment.paycost = 0
			payment.account = 'TRADE-V | 跨境贸易 一键直达'
     
	        payment.member_id = payment.op_id = @user.member_id
	        payment.pay_account = @user.login_name

			payment.ip = request.remote_ip

			payment.t_begin = payment.t_confirm = Time.now.to_i

			payment.memo = nil  if pay_app_id == 'bcom'
			
			payment.pay_bill = Ecstore::Bill.new do |bill|
				bill.rel_id  = rel_id
				bill.bill_type = "payments"
				bill.pay_object  = "order"
				bill.money = @order.pay_amount
			end
		end

		@payment.money = @payment.cur_money = @order.pay_amount
		shop_id = params[:shop_id]
		if @payment.save
	      if @payment.pay_app_id=='wxpay'
	      	supplier_id = params[:supplier_id]

	      	if supplier_id == '98' 
	      		id = 98	#万家物流微信支付接口
	      	else
	      		id = 78 #贸威微信支付接口
	        end
	      	
	        redirect_to "/vshop/#{id}/payments?payment_id=#{@payment.payment_id}&supplier_id=#{supplier_id}&shop_id=#{shop_id}&shop_id=&showwxpaytitle=1"
	  
	      else
	        redirect_to pay_payment_path(@payment.payment_id)
	      end

		else
			redirect_to order_url(@order)
		end
  end

  def debug
    render :text=>"show"
  end

	def show
		@payment = Ecstore::Payment.find_by_payment_id(params[:id])
	end

	def pay
		@payment = Ecstore::Payment.find(params[:id])
      	if @payment && @payment.status == 'ready'
	        adapter = @payment.pay_app_id
	        order_id = @payment.pay_bill.rel_id
	        @modec_pay = ModecPay.new adapter do |pay|
		        pay.return_url = "#{site}/payments/#{@payment.payment_id}/#{adapter}/callback"
		        pay.notify_url = "#{site}/payments/#{@payment.payment_id}/#{adapter}/notify"
				pay.pay_id = @payment.payment_id
				pay.pay_amount = @payment.cur_money.to_f
				pay.pay_time = Time.now
				pay.subject = "贸威订单(#{order_id})"
				pay.installment = @payment.pay_bill.order.installment if @payment.pay_bill.order
		        pay.openid = @user.account.login_name
		        pay.spbill_create_ip = request.remote_ip
		    end

		    if adapter=='alipaywap'
		        render :text=>@modec_pay.html_form_alipaywap
		    elsif adapter=='wxpay'
		        render :inline=>@modec_pay.html_form_wxpay
		    else
				render :inline=>@modec_pay.html_form
		    end

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

	def callback
		ModecPay.logger.info "[#{Time.now}][#{request.remote_ip}] #{request.request_method} \"#{request.fullpath}\""

		@payment = Ecstore::Payment.find(params.delete(:id))
		return redirect_to detail_order_path(@payment.pay_bill.order) if @payment&&@payment.paid?
		
		adapter  = params.delete(:adapter)
		params.delete :controller
		params.delete :action

		@payment.payment_log.update_attributes({:return_ip=>request.remote_ip,:return_params=> params,:returned_at=>Time.now}) if @payment.payment_log

		@order = @payment.pay_bill.order
		@user = @payment.user

		result = ModecPay.verify_return(adapter, params, { :bill99_redirect_url=>detail_order_url(@order),:ip=>request.remote_ip })

		if result.is_a?(Hash) && result.present?
			response = result.delete(:response)
			if result.delete(:payment_id) == @payment.payment_id.to_s && !@payment.paid?
				@payment.update_attributes(result)
				@order.update_attributes(:pay_status=>'1')

        unless @order.shop_id.nil?
          shop_id=  @order.shop_id
           @shop=  Ecstore::Shop.find(shop_id)
            if @shop.permission_branch=="-2"
                  s_order=0
                  @ord=  Ecstore::Order.all(:conditions => "shop_id = #{shop_id}", :select => "SUM(final_amount)")
                  @ord.each do |row|
                   s_order+= row["SUM(final_amount)"]
                       end
                    if s_order>200
                      @shop.update_attributes(:permission_branch=>"-1")
                    end
            else

            end
        end

        member_id=@order.member_id
        @member = Ecstore::Member.find(member_id)
        @users = Ecstore::User.find(member_id)

          advance=@member.advance-@order.final_pay

        @member.update_attribute(:advance,advance)
        advances =  @users.member_advances.order("log_id asc").last
        if advances
          shop_advance = advances.shop_advance
        else
          shop_advance =@member.advance
        end
        shop_advance += @order.final_pay

        Ecstore::MemberAdvance.create(:member_id=>member_id,
                                      :money=>@order.final_pay,
                                      :message=>"预充值消费:#{@order.final_pay}",
                                      :mtime=>Time.now.to_i,
                                      :memo=>"用户本人操作",
                                      :order_id=>@order.order_id,
                                      :import_money=>0,
                                      :explode_money=>@order.final_pay,
                                      :member_advance=>(advance),
                                      :shop_advance=>shop_advance,
                                      :disabled=>'false')



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
		
		#redirect_to detail_order_path(@payment.pay_bill.order)
    if @order.supplier_id==98
      redirect_to  "/orders/wuliu_show_order?id=#{@payment.pay_bill.order.order_id}&supplier_id=#{@order.supplier_id}"
    else
    redirect_to  "/orders/mobile_show_order?id=#{@payment.pay_bill.order.order_id}&supplier_id=#{@order.supplier_id}"
      end
	end

	def test_notify
		

		@payment = Ecstore::Payment.find(params[:id])
		if @payment #&& @payment.status == 'ready'
			adapter = @payment.pay_app_id
			order_id = @payment.pay_bill.rel_id

			@modec_pay = ModecPay.new adapter do |pay|
				pay.action = "/payments/#{@payment.payment_id}/#{adapter}/notify"
				pay.method = "post"

				pay.fields = {}

				time = Time.now
        if adapter == "ips"
          # ===Ips
          pay.fields["Mer_code"] = "000015"
          pay.fields["Billno"] = @payment.payment_id,
          pay.fields["Amount"] = @payment.cur_money.round(2)
          pay.fields["Date"] = time.strftime("%Y-%m-%d")
          pay.fields["Currency_Type"] = "RMB"
          pay.fields["Gateway_Type"] = "01"
          pay.fields["Lang"] = "GB"
          pay.fields["Merchanturl"] = ""
          pay.fields["FailUrl"] = @payment.payment_id
          pay.fields["ErrorUrl"] = ""
          pay.fields["Attach"] = ""
          pay.fields["OrderEncodeType"] = "5"
          pay.fields["RetEncodeType"] = "17"
          pay.fields["Rettype"] = "1"
          pay.fields["ServerUrl"] = ""
          pay.fields["SignMD5"] = ""
        end
				if adapter == "alipay"
					# ===Alipay
					pay.fields["discount"] = "0.00"
					pay.fields["payment_type"] = "1"
					pay.fields["subject"] = "摩登客订单(#{order_id})"
					pay.fields["trade_no"] = "2013091823959388"
					pay.fields["buyer_email"] = "596849181@qq.com"
					pay.fields["gmt_create"] = "2013-08-14 19:08:03"
					pay.fields["notify_type"] = "trade_status_sync"
					pay.fields["quantity"] = "1"
					pay.fields["out_trade_no"] = @payment.payment_id
					pay.fields["seller_id"] = "2088701875473608"
					pay.fields["notify_time"] = time.strftime("%Y-%m-%d %H:%M:%S")
					pay.fields["trade_status"] = "TRADE_SUCCESS"
					pay.fields["is_total_fee_adjust"] = "N"
					pay.fields["total_fee"] = @payment.cur_money.round(2)
					pay.fields["gmt_payment"] = (time - 30.seconds).strftime("%Y-%m-%d %H:%M:%S")
					pay.fields["seller_email"] = "eileen.gu@i-modec.com"
					pay.fields["price"] = @payment.cur_money.round(2)
					pay.fields["buyer_id"] = "2088102350773884"
					pay.fields["notify_id"] = "1b2658003817950ee56fb6785ce505086w"
					pay.fields["use_coupon"] = "N"
					pay.fields["sign_type"] = "MD5"
				end

				if adapter == "99bill"
					pay.sorter = []
					pay.fields = {
						"merchantAcctId"=>"1002214092801",
						"version"=>"v2.0",
						"language"=>"1",
						"signType"=>"1",
						"payType"=>"10",
						"bankId"=>"BOC",
						"orderId"=>@payment.payment_id,
						"orderTime"=>(time - 5.seconds).strftime("%Y%m%d%H%M%S"),
						"orderAmount"=>(@payment.cur_money * 100).to_i,
						"dealId"=>(0..9).collect{ rand(10) }.join,
						"bankDealId"=>"130901261143",
						"dealTime"=>time.strftime("%Y%m%d%H%M%S"),
						"payAmount"=>(@payment.cur_money * 100).to_i,
						"fee"=>(@payment.cur_money * 100 * 0.004).to_i,
						"ext1"=>"",
						"ext2"=>"",
						"payResult"=>"10",
						"errCode"=>""}
				end
				if adapter == "bcom"
					# ===Bcom
					# 301310053119675|13786093763144|929.00|CNY|20130908| |20130908|111153|ABFF516B|1|5.57|2| | |119.165.52.9|www.i-modec.com| |
					pay.sorter =[]
					src = {
						'MERCHNO'=>pay.mer_id,
						'orderno'=>@payment.payment_id,
						'tranamount'=>@payment.cur_money.round(2),
						'TRANCURRTYPE'=>"CNY",
						'paybatno'=>time.strftime("%Y%m%d"),
						'MERCHBATCHNO'=>'',
						'TRANDATE'=>(time - 5.seconds).strftime("%Y%m%d"),
						'TRANTIME'=>(time - 5.seconds).strftime("%H%M%S"),
						'SERIALNO'=>"0000#{rand(10)}#{rand(10)}#{rand(10)}",
						'TRANRST'=>'1',
						'FEESUM'=>(@payment.cur_money * 0.006).round(2),
						'CARDTYPE'=>'2',
						'BankMoNo'=>'',
						'ErrDis'=>''
					}.collect{ |key,val| val }.join("|")
					sign = ModecPay::Bcom::Sign.new.generate_sign(src)
					pay.fields['notifyMsg'] = "#{src}|#{sign}"
				end
				
				if adapter == "icbc"
					# === Icbc
					pay.sorter = []
					b2c_res = {
						'interfaceName'=>'ICBC_PERBANK_B2C',
						'interfaceVersion'=>'1.0.0.11',
						'orderInfo' => {
							'orderDate'=>time.strftime('%Y%m%d%H%M%S'),
							'curType'=>'001',
							'merID'=>pay.mer_id,
							'subOrderInfoList'=>{
								'subOrderInfo'=>{
									'orderid'=>@payment.payment_id,
									'amount'=>(@payment.cur_money*100).round.to_s,
									'installmentTimes'=>(@payment.pay_bill.order.installment || 1).to_s,
									'merAcct'=>'1001258219300435028',
									'tranSerialNo'=>'2013092315051111'
								}
							}
						},
						'custom'=>{
							'verifyJoinFlag'=>'0',
							'JoinFlag'=>'0',
							'UserNum'=>''
						},
						'bank'=>{
							'TranBatchNo'=>'',
							'notifyDate'=>(time+5.seconds).strftime('%Y%m%d%H%M%S'),
							'tranStat'=>'1',
							'comment'=>''
						}
					}

					xml = '<?xml version="1.0" encoding="GBK" standalone="no"?>'+b2c_res.to_xml(:root=>"B2CRes",:skip_instruct=>true,:indent=>0)
					sign = ModecPay::Icbc::Sign.new
					pay.fields['merVAR'] = ''
					pay.fields['notifyData'] = sign.encodebase64(xml)
					pay.fields['signMsg'] = sign.generate_sign2(xml)
				end
				
			end

			render :inline=>@modec_pay.html_form
		else
			render :text=>"alreay paid"
		end
	end

	def notify
		ModecPay.logger.info "[#{Time.now}][#{request.remote_ip}] #{request.request_method} \"#{request.fullpath}\" params : #{ params.to_s }"

		@payment = Ecstore::Payment.find(params.delete(:id))

		return render :nothing=>true, :status=>:forbidden if @payment.paid?

		adapter  = params.delete(:adapter)
		params.delete :controller
		params.delete :action

		@order = @payment.pay_bill.order
		@user = @payment.user

		result = ModecPay.verify_notify(adapter,params,{ :bill99_redirect_url=>"#{site}/#{order_path(@order)}",:ip=>request.remote_ip })

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

end
