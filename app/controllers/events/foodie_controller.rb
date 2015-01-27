class Events::FoodieController < ApplicationController
  layout "tradev"
  def index
    @supplier=Ecstore::Supplier.find(params[:supplier_id])
    @events  = Imodec::Event.paginate(:page => params[:page], :conditions =>{:terminal=>"mobile"},:per_page => 20,:order=>"created_at desc")

  end

  def new
    @supplier=Ecstore::Supplier.find(params[:supplier_id])
    @event= Imodec::Event.find(params[:id])
    @applicants = @event.applicants.paginate(:page => params[:page], :per_page => 20,:order=>"created_at desc")

    @action_url="/events/foodie/add_foodie"
  end

  def add_foodie
    @user.update_attributes(:user_desc=>params[:user_desc])

    @applicant = Imodec::Applicant.new(params[:applicant])
    @app= Imodec::Applicant.where(:member_id=>params[:applicant][:member_id],:event_id=>@applicant.event_id)
     if @app.size>0
       render "error"
     else

       if @applicant.save
         render "create"
       else
         render "error"
       end
     end
  end


  def user_foodie
    @supplier=Ecstore::Supplier.find(params[:supplier_id])
    @applicant = Imodec::Applicant.where(:member_id=>@user.member_id).order("created_at desc")

  end


  def detail
    @supplier=Ecstore::Supplier.find(params[:supplier_id])
  end


  end