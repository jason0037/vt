class Admin::EventsController < Admin::BaseController
  include Admin::SessionsHelper
	def index
		@events  = Imodec::Event.paginate(:page => params[:page], :per_page => 20,:order=>"created_at desc")
	end

	def new
		@create_or_update_path = admin_events_path
		@event = Imodec::Event.new
	end

	def show
		@event = Imodec::Event.find(params[:id])
		# @applicants = @event.applicants
	end

	def applicants
		@event = Imodec::Event.find(params[:id])
		@applicants = @event.applicants.paginate(:page => params[:page], :per_page => 20,:order=>"created_at desc")
	end
	
	def edit

		@event = Imodec::Event.find(params[:id])
		@create_or_update_path = admin_event_path(@event)
	end

	def create
		@event = Imodec::Event.new(params[:imodec_event]) do |ev|
    ev.startime= Time.parse(params[:imodec_event][:startime]).to_i
    ev.endtime= Time.parse(params[:imodec_event][:endtime]).to_i
      end
		if @event.save
			redirect_to edit_admin_event_url(@event)
		else
			render "new"
		end

	end

	def update
		@event = Imodec::Event.find(params[:id])
    startime=params[:imodec_event].delete(:startime)
    endtime= params[:imodec_event].delete(:endtime)
    startime= Time.parse(startime).to_i
    endtime= Time.parse(endtime).to_i

		if @event.update_attributes(params[:imodec_event].merge!(:startime=>startime,:endtime=>endtime))
    redirect_to edit_admin_event_url(@event)
		else
			render action: "edit"
		end
	end

	def destroy
		@event = Imodec::Event.find(params[:id])
    		@event.destroy

	      respond_to do |format|
	        format.html { redirect_to admin_events_url }
	        format.json { head :no_content }
	      end
	end
end
