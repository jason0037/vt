#encoding:utf-8
class Admin::MemberCardsController < Admin::BaseController

	def update
		@member_card = Ecstore::MemberCard.find(params[:id])
		
		if @member_card.update_attributes(params[:user_card])

			log = params[:user_card].collect do |key,value|
				if %w(user_id buyer_id).include?(key)
					u = Ecstore::User.find(value)
					value = u.account.login_name if u&&u.account
				end
				value = "是" if value.is_a?(TrueClass)
				value = "否" if value.is_a?(FalseClass)
				I18n.t("card.#{key}") + "=" + value.to_s
			end.join(",")

			Ecstore::CardLog.create(:member_id=>current_admin.account_id,
			                                                :card_id=>@member_card.card_id,
			                                                :message=>"修改: #{log}")
		end
		respond_to do |format|
			format.js
		end
	end
	
end
