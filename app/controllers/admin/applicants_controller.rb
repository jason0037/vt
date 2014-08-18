class Admin::ApplicantsController < Admin::BaseController
	def index
		@applicants  = Imodec::Applicant.paginate(:page => params[:page], :per_page => 20,:order=>"created_at desc")
	end

	def destroy

  end


end
