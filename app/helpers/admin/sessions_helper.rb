module Admin::SessionsHelper


	def current_admin
		@admin ||= Ecstore::Account.find_by_account_id(session[:admin_id])
	end

	def current_admin=(admin)
		@admin = admin
	end
	
	def admin_signed_in?
		!current_admin.nil?
	end

	def admin_sign_in(admin)
		session[:admin_id] = admin.account_id
		current_admin = admin
	end

	def admin_sign_out
		current_admin = nil
		session.delete :admin_id
	end

	def after_admin_sign_in_path
		admin_goods_path
	end

	# alias :current_user :current_admin


end
