class EventsController < ApplicationController
	# layout 'event'
  layout 'left_cheuks'

	def show
		@event =  Imodec::Event.find(params[:id])
	end

	def index
		@events  = Imodec::Event.paginate(:page => params[:page], :per_page => 20,:order=>"created_at desc")
	end
end
