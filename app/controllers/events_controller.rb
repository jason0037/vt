class EventsController < ApplicationController
	# layout 'event'
	layout 'magazine'

	def show
		@event =  Imodec::Event.find(params[:id])
	end
end
