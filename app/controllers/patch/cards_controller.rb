#encoding:utf-8
class Patch::CardsController < ApplicationController
	# skip_before_filter :authorize_user!
	before_filter :find_user

	layout "patch"

	before_filter do
		clear_breadcrumbs
		add_breadcrumb("我的贸威",:member_path)
	end


	def index
		@tab = params[:tab] || "bought"
		case @tab
			when "bought"
				@cards = Ecstore::Card.sold_cards_of(@user.member_id)
			when "unactive"
				@cards = Ecstore::Card.unactive_cards_of(@user.mobile)
			when "activated"
				@cards = Ecstore::Card.activated_cards_of(@user.mobile)
		end

		@cards =  @cards.paginate(:page=>params[:page],:per_page=>10)

		add_breadcrumb("我的VIP卡")
	end

	def loss
		@card =  Ecstore::Card.find(params[:id])

		add_breadcrumb("挂失")
	end

	def confirm_lost
		@card =  Ecstore::Card.find(params[:id])
		sms_code = params[:sms_code]
		operator = params[:operator]
		if @user.check_sms(sms_code)
			@card.update_attribute :status,"锁定"

			if operator == "buyer"
				begin
					@sms_log ||= Logger.new('log/sms.log')
					text = "您购买的摩登客VIP卡#{@card.no}已锁定,如有疑问请致电客服18917937822[I-Modec摩登客]"
					if Sms.send(@card.member_card.buyer_tel,text)
						tel = @card.member_card.buyer_tel
						@sms_log.info("[#{@user.login_name}][#{Time.now}][#{tel}]#{text}")
					end
					text = "您的摩登客VIP卡#{@card.no}已被锁定,如有疑问请致电客服18917937822[I-Modec摩登客]"
					if Sms.send(@card.member_card.user_tel,text)
						tel = @card.member_card.user_tel
						@sms_log.info("[#{@user.login_name}][#{Time.now}][#{tel}]#{text}")
					end
				rescue
				end
			end

			if operator == "user"
				begin
					@sms_log ||= Logger.new('log/sms.log')
					text = "您购买的摩登客VIP卡#{@card.no}已被#{mask(@card.member_card.user_tel)}挂失,如有疑问请致电18917937822[I-Modec摩登客]"
					if Sms.send(@card.member_card.buyer_tel,text)
						tel = @card.member_card.buyer_tel
						@sms_log.info("[#{@user.login_name}][#{Time.now}][#{tel}]#{text}")
					end
					text = "您的摩登客VIP卡#{@card.no}已锁定,如有疑问请致电客服18917937822[I-Modec摩登客]"
					if Sms.send(@card.member_card.user_tel,text)
						tel = @card.member_card.user_tel
						@sms_log.info("[#{@user.login_name}][#{Time.now}][#{tel}]#{text}")
					end
				rescue
				end
			end

			render "patch/cards/confirm_lost"
		else
			flash[:error] = "验证码错误"
			redirect_to loss_card_path(@card,:operator=>operator)
		end
	end
	def cancel_loss
		@card =  Ecstore::Card.find(params[:id])

		add_breadcrumb("恢复")
	end
	
	def confirm_cancel
		@card =  Ecstore::Card.find(params[:id])
		sms_code = params[:sms_code]
		operator = params[:operator]

		if @user.check_sms(sms_code)
			@user.update_attribute :sms_code,nil
			@card.update_attribute :status,"正常"

			if operator == "buyer"
				begin
					@sms_log ||= Logger.new('log/sms.log')
					text = "您购买的摩登客VIP卡#{@card.no}已被重新启用,如有疑问请致电客服18917937822[I-Modec摩登客]"
					if Sms.send(@card.member_card.buyer_tel,text)
						tel = @card.member_card.buyer_tel
						@sms_log.info("[#{@user.login_name}][#{Time.now}][#{tel}]#{text}")
					end
					text = "您的摩登客VIP卡#{@card.no}已被重新启用,如有疑问请致电客服18917937822[I-Modec摩登客]"
					if Sms.send(@card.member_card.user_tel,text)
						tel = @card.member_card.user_tel
						@sms_log.info("[#{@user.login_name}][#{Time.now}][#{tel}]#{text}")
					end
				rescue
				end
			end

			if operator == "user"
				begin
					@sms_log ||= Logger.new('log/sms.log')
					text = "您购买的摩登客VIP卡#{@card.no}已被#{mask(@card.member_card.buyer_tel)}启用,如有疑问请致电18917937822[I-Modec摩登客]"
					if Sms.send(@card.member_card.buyer_tel,text)
						tel = @card.member_card.buyer_tel
						@sms_log.info("[#{@user.login_name}][#{Time.now}][#{tel}]#{text}")
					end
					text = "您的摩登客VIP卡#{@card.no}已被重新启用,如有疑问请致电客服18917937822[I-Modec摩登客]"
					if Sms.send(@card.member_card.user_tel,text)
						tel = @card.member_card.user_tel
						@sms_log.info("[#{@user.login_name}][#{Time.now}][#{tel}]#{text}")
					end
				rescue
				end
			end

			render "patch/cards/confirm_cancel"
		else
			flash[:error] = "验证码错误"
			render "patch/cards/cancel_loss"
		end
	end

	def contact
		@card =  Ecstore::Card.find(params[:id])

		add_breadcrumb("修改联系方式 ")
	end

	def buyer_tel
		add_breadcrumb("修改购卡人联系方式 ")
		@card =  Ecstore::Card.find(params[:id])
	end

	def update_buyer_tel
		@card =  Ecstore::Card.find(params[:id])
		@sms_code  = params[:sms_code]
		@buyer_tel = params[:buyer_tel]
		if @sms_code.blank?
			@card.errors.add :sms_code, "请填写验证码"
			render "patch/cards/buyer_tel"
			return
		end
		if @buyer_tel.blank?
			@card.errors.add :buyer_tel, "请填写手机号码"
			render "patch/cards/buyer_tel"
			return
		end
		
		if  @user.check_sms(@sms_code)
			@card.member_card.update_attribute :buyer_tel, @buyer_tel

			begin
				@sms_log ||= Logger.new('log/sms.log')
				text = "您购买的摩登客VIP卡#{@card.no}已更改购卡人的联系方式,如有疑问请致电18917937822[I-Modec摩登客]"
				if Sms.send(@buyer_tel,text)
					tel = @buyer_tel
					@sms_log.info("[#{@user.login_name}][#{Time.now}][#{tel}]#{text}")
				end
			rescue
			end

		else
			@card.errors.add :sms_code, "验证码错误"
			render "patch/cards/buyer_tel"
		end
	end

	def user_tel
		add_breadcrumb("修改用卡人联系方式 ")
		@card =  Ecstore::Card.find(params[:id])
	end

	def update_user_tel
		@card =  Ecstore::Card.find(params[:id])
		@sms_code  = params[:sms_code]
		@user_tel = params[:user_tel]

		

		if @sms_code.blank?
			@card.errors.add :sms_code, "请填写验证码"
			render "patch/cards/user_tel"
			return
		end
		if @user_tel.blank?
			@card.errors.add :user_tel, "请填写手机号码"
			render "patch/cards/user_tel"
			return
		end

		if  @user.check_sms(@sms_code)
			@card.member_card.update_attribute :user_tel, @user_tel
			if @card.use_status
				begin
					@sms_log ||= Logger.new('log/sms.log')
					text = "您的摩登客VIP卡#{@card.no}联系方式已改为#{mask(@user_tel)}如有疑问请致电18917937822[I-Modec摩登客]"
					if Sms.send(@user_tel,text)
						tel =@user_tel
						@sms_log.info("[#{@user.login_name}][#{Time.now}][#{tel}]#{text}")
					end
				rescue
				end
			else
				begin
					@sms_log ||= Logger.new('log/sms.log')
					text = "您购买的摩登客VIP卡#{@card.no}已更改指定用卡人的联系方式,如有疑问请致电18917937822[I-Modec摩登客]"
					if Sms.send(@card.member_card.buyer_tel,text)
						tel = @card.member_card.buyer_tel
						@sms_log.info("[#{@user.login_name}][#{Time.now}][#{tel}]#{text}")
					end
				rescue
				end
			end
		else
			@card.errors.add :sms_code, "验证码错误"
			render "patch/cards/user_tel"
			return
		end
	end

	def activation
		@card =  Ecstore::Card.find(params[:id])
		if @card.used?  
			@message = "该卡已被激活，不能再次激活"
			render "patch/cards/message"
		else
			render "memberships/cards/activation/validate"
		end
	end

end
