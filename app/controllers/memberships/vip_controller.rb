class Memberships::VipController < ApplicationController
  # layout 'memberships'
  layout 'standard'
  
  before_filter :find_user
  # skip_before_filter :authorize_user!
  
  def index
  	
  end
  
end