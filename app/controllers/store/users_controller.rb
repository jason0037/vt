class Store::UsersController < ApplicationController
	before_filter :find_user

	def update
		custom_values = params[:custom_values].collect{ |k,v| v}.to_json
		@user.update_attribute(:custom_values,custom_values)
		render :nothing=>true
	end
end
