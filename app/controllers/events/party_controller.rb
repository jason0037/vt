class Events::PartyController < ApplicationController
  layout "tradev"
  def index
    if @user
    @supplier=Ecstore::Supplier.find(params[:supplier_id])

   end



  end

  def stepone

    @users=Ecstore::User.where(:member_id=>@user.member_id).first
     if @users.update_attributes(params[:user])

     end
    redirect_to "/events/party?supplier_id=78&step=2"
     end

   def steptwo

     @event = Imodec::Event.new params[:event]
     if @event.save
       redirect_to "/events/party?supplier_id=78&step=3"
     end
   end

  def list
    @supplier=Ecstore::Supplier.find(params[:supplier_id])
    @events  = Imodec::Event.paginate(:page => params[:page], :per_page => 20,:order=>"created_at desc")

  end

  def user_party
   @supplier=Ecstore::Supplier.find(params[:supplier_id])
    @events  = Imodec::Event.paginate(:page => params[:page], :per_page => 20,:order=>"created_at desc",:conditions =>{
        :terminal=>"mobile",:member_id=>@user.member_id})

  end


  def detail
    @supplier=Ecstore::Supplier.find(params[:supplier_id])
    @event = Imodec::Event.find(params[:id])
    @applicants = @event.applicants.paginate(:page => params[:page], :per_page => 20,:order=>"created_at desc")
  end

  end