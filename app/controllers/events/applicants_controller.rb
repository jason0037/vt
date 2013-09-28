class Events::ApplicantsController < ApplicationController
  layout  nil
  def create
  	@applicant = Imodec::Applicant.new(params[:applicant])
  	
  	if @applicant.save
  		render "create"
	else
		render "error"
	end
  end

end
