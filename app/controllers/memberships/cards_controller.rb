#encoding:utf-8
require 'sms'
class Memberships::CardsController < ApplicationController
	# skip_before_filter :authorize_user!
	before_filter :find_user
	layout 'memberships'

	def show
		if params[:card].has_key?(:card_no)
			@card = Ecstore::Card.find_by_no(params[:card][:card_no])
			if @card
				render "memberships/cards/confirm_activation"
			else
				render "memberships/cards/activation"
			end
		end

		if params[:card].has_key?(:user_tel)
			
		end
	end

	def search
		if params[:search].has_key?(:no)
			card_no = params[:search][:no]
			@card = Ecstore::Card.find_by_no(card_no)

			unless @card
			      flash[:error] = '您输入的VIP卡号不存在'
				render "memberships/cards/activation"
				return
			end

			unless @card.can_use?
				flash[:error] = '您输入的VIP卡号不能激活,请检查卡状态'
				render "memberships/cards/activation"
				return
			end

			if @card.used?
				flash[:error] = '您输入的VIP卡号已被激活，请核实'
				render "memberships/cards/activation"
				return
			end

			render "memberships/cards/activation/validate"
		end
		
		if params[:search].has_key?(:user_tel)
			user_tel = params[:search][:user_tel]
			@cards = Ecstore::MemberCard.where(:user_tel=>user_tel).collect do |mc|
				mc.card
			end
			render "memberships/cards/activation/list_cards"
		end
	end

	def purchase
		@level = params[:level] || "you"
		@buyer_tel = @user.mobile if @user
	end

	def confirm_buyer
		@buyer_tel = params[:buyer_tel]
		@level = params[:level]
		if @buyer_tel.blank? || !(/^[1-9][0-9]{10}$/ =~ @buyer_tel)
			@error = "请输入正确的手机号码"
			render "memberships/cards/purchase"
			return
		end
		if @user.mobile == @buyer_tel
			redirect_to user_card_url(:level=>@level,:buyer_tel=>@buyer_tel)
		else
			render "memberships/cards/purchase/update_mobile"
		end
	end

	def modify_mobile
		@buyer_tel = params[:buyer_tel]
		@level = params[:level]
		@user.update_attribute :mobile, @buyer_tel
		redirect_to user_card_url(:level=>@level,:buyer_tel=>@buyer_tel)
	end

	def confirm_user
		para = params[:member_card].merge!(:buyer_id=>@user.member_id)
		level = params[:level]
		product_bn = Ecstore::Config.find_by_key("#{level}_bn").value
		@product = Ecstore::Product.find_by_bn(product_bn)

		@card = Ecstore::Card.where(:value=>@product.price,
									  :card_type=>"A",
									  :sale_status=>false,
									  :use_status=>false,
									  :status=>"正常",
									  :pay_status=>false).first

		unless @card
			render "memberships/cards/purchase/lack"
			return
		end

		@card.member_card = Ecstore::MemberCard.new(para)
		
		if @card.save(:validate=>false)
			@cart = Ecstore::Cart.where(:obj_ident=>"goods_#{@product.goods_id}_#{@product.product_id}",
							  :member_id=>@user.member_id).first_or_initialize do |cart|
				cart.obj_type = "goods"
				cart.quantity = 1
				cart.time = Time.now.to_i
			end
			if @cart.new_record?
				@cart.save
			else
				Ecstore::Cart.where(:obj_ident=>@cart.obj_ident,:member_id=>@cart.member_id).update_all(:quantity=>@cart.quantity+1)
			end

			# begin
			# 	@sms_log ||= Logger.new('log/sms.log')
			# 	text = "您已成功购买摩登客VIP卡,感谢您对我们的支持，如需帮助可致电客服18917937822[I-Modec摩登客]"
			# 	tel = @card.member_card.buyer_tel
			# 	if Sms.send(@card.member_card.buyer_tel,text)
			# 		@sms_log.info("[#{@user.login_name}][#{Time.now}][#{tel}]#{text}")
			# 	end
			# rescue
			# 	@sms_log.info("[#{@user.login_name}][#{Time.now}]购买VIP卡,发送短信失败")
			# end
			

			Ecstore::CardLog.create(:member_id=>@user.member_id,
                                                :card_id=>@card.id,
                                                :message=>"加入购物车")

			redirect_to "/cart.html"
		else
			@error_msg = "提交订单失败，请联系客服:18917937822"
			render "memberships/cards/purchase/error"
		end
	end

	def confirm_activation
		@card = Ecstore::Card.find_by_no(params[:card][:no])
		if @card.card_type == "A"
			sms_code = params[:sms_code]

			unless @card.can_use?
				@card.errors.add(:sms_code, "该卡不能激活，请检查卡状态。")
				render "memberships/cards/activation/validate"
				return
			end


			if sms_code.blank?
				@card.errors.add(:sms_code, "请输入激活码")
				render "memberships/cards/activation/validate"
				return
			end
			
			if @user.check_sms(sms_code)
				if @user.mobile != @card.member_card.user_tel
					render "memberships/cards/activation/update_mobile"
				else
					render "memberships/cards/activation/confirm"
				end

				return
			else
				@card.errors.add(:sms_code, "激活码错误或者失效，请重新发送")
				render "memberships/cards/activation/validate"
				return
			end
		end

		if @card.card_type == "B"
			password = params[:card][:password]

			unless @card.can_use?
				@card.errors.add(:password, "该卡不能激活，请检查卡状态。")
				render "memberships/cards/activation/validate"
				return
			end


			if password.blank?
				@card.errors.add(:password, "请输入密码")
				render "memberships/cards/activation/validate"
				return
			end

			if @card.password != password
				if @card.try_password_times < 4
					@card.increment! :try_password_times
					@card.errors.add(:password, "密码错误,剩#{ 5 - @card.try_password_times }余次尝试机会。")
					render "memberships/cards/activation/validate"
				else
					@card.update_attribute :status,"锁定"
					render "memberships/cards/activation/locked"
				end
			else
				render "memberships/cards/activation/mobile"
				return
			end

		end
	end

	def update_mobile
		@card = Ecstore::Card.find_by_no(params[:card][:no])
		@user.update_attribute :mobile, @card.member_card.user_tel
		@user.update_attribute :sms_validate,'true'
		render "memberships/cards/activation/confirm"
	end

	def input_mobile
		@card = Ecstore::Card.find_by_no(params[:card][:no])
		tel = params[:tel]
		sms_code = params[:sms_code]

		@card.errors.add(:tel,"请输入手机号码") if tel.blank?
		@card.errors.add(:sms_code,"请输入激活码")  if sms_code.blank?
		@card.errors.add(:sms_code,"激活码错误") if sms_code != @user.sms_code

		if @card.errors.messages.empty?
			# @user.update_attribute :mobile, tel
			# @user.update_attribute :sms_validate, true
			if @card.member_card
				@card.member_card.update_attribute :user_tel,tel
				@card.member_card.update_attribute :user_id,@user.member_id
			else
				@member_card  = Ecstore::MemberCard.new do |mc|
					mc.card_id = @card.id
					mc.user_tel = tel
					mc.user_id = @user.member_id
				end
				@member_card.save(:validate=>false)
			end
			

			render "memberships/cards/activation/confirm"
		end

	end

	def validate_activation
		if params[:card][:no].blank?
			@error = "请输入VIP卡号"
			render "memberships/cards/activation"
			return
		end

		@card = Ecstore::Card.find_by_no(params[:card][:no])

		if @card.nil?
			@error = "VIP卡号不存在"
			render "memberships/cards/activation"
			return
		end

		if @card.used?
			@error = "您输入的卡号已激活，请核实"
			render "memberships/cards/activation"
			return
		end

		if @card.can_use?
			tel = @card.member_card.buyer_tel
			sms_code = rand(1000000).to_s(16)
			text = "您的VIP卡验证码是：#{sms_code}，如此条验证码非您本人申请，请立即致电客服18917937822核实[I-Modec摩登客]"
			@sms_log ||= Logger.new('log/sms.log')
			begin
				if Sms.send(tel,text)
					@user.update_attribute :sms_code, sms_code
					@sms_log.info("[#{@user.login_name}][#{Time.now}][#{tel}]发送手机验证码: #{sms_code}")
				end
			rescue Exception => e
				@sms_log.info("[#{@user.login_name}][#{Time.now}][#{tel}]发送手机验证码失败:#{e}")
			end
			
			render "memberships/cards/activation/validate"
		else
			@error = "您输入的卡号不能激活"
			render "memberships/cards/activation"
			return
		end

	end

	def select
		card_no = params[:card]
		@card =  Ecstore::Card.find_by_no(card_no)
		render "memberships/cards/activation/validate"
	end

	def cancel_mobile
		@card =  Ecstore::Card.find_by_no(params[:no])
		render "memberships/cards/activation/confirm"
	end

	def activate
		@card = Ecstore::Card.find_by_no(params[:card][:no])

		if @card.can_use? && !@card.used?
			
			
			advance = @user.member_advances.order("log_id asc").last
			shop_advance = 0
			 if advance
				shop_advance = advance.shop_advance
			else
				shop_advance = @user.advance
			end
			shop_advance += @card.value
			Ecstore::MemberAdvance.create(:member_id=>@user.member_id,
											  :money=>@card.value,
											  :message=>"会员卡激活,卡号:#{@card.no}",
											  :mtime=>Time.now.to_i,
											  :memo=>"用户本人操作",
											  :import_money=>@card.value,
											  :explode_money=>0,
											  :member_advance=>(@user.advance + @card.value),
											  :shop_advance=>shop_advance,
											  :disabled=>'false')
			@user.update_attribute :advance, (@card.value + @user.advance)
			@card.update_attribute :use_status,true
			@card.update_attribute :used_at,Time.now
			@card.member_card.update_attribute :user_id,@user.member_id

			
			begin
				@sms_log ||= Logger.new('log/sms.log')
				text = "您购买的摩登客VIP卡#{@card.no}已被#{mask @card.member_card.user_tel}激活,如有疑问请致电18917937822[I-Modec摩登客]"
				if Sms.send(@card.member_card.buyer_tel,text)
					tel = @card.member_card.buyer_tel
					@sms_log.info("[#{@user.login_name}][#{Time.now}][#{tel}]#{text}")
				end

				text = "您的摩登客VIP卡#{@card.no}已激活,如有疑问请致电客服18917937822[I-Modec摩登客]"
				if Sms.send(@card.member_card.user_tel,text)
					tel = @card.member_card.user_tel
					@sms_log.info("[#{@user.login_name}][#{Time.now}][#{tel}]#{text}")
				end

			rescue
				@sms_log.info("[#{@user.login_name}][#{Time.now}]激活VIP卡,发送短信失败")
			end

			Ecstore::CardLog.create(:member_id=>@user.member_id,
                                                :card_id=>@card.id,
                                                :message=>"会员卡激活,用户本人操作")


			render "memberships/cards/activation/complete"
		else
			render "memberships/cards/activation/error"
		end
	end

	def send_sms_code
		sms_code = rand(1000000).to_s(16)
		tel = params[:tel]
		text = "您的VIP卡验证码是：#{sms_code}，如此条验证码非您本人申请，请立即致电客服18917937822核实[I-Modec摩登客]"

		
		@sms_log ||= Logger.new('log/sms.log')
		if Sms.send(tel,text)
			@user.update_attribute :sms_code, sms_code
			@user.update_attribute :sent_sms_at, Time.now
			@sms_log.info("[#{@user.login_name}][#{Time.now}][#{tel}]发送手机验证码: #{sms_code}")

			render :json=>{:code=>'t',:msg=>'验证码已发送'}.to_json
		end

	rescue Exception=> e
		@sms_log.info("[#{@user.login_name}][#{Time.now}][#{tel}]发送手机验证码失败:#{e}")
		render :json=>{ :code=>'f',:msg=>e }.to_json
	end


end
