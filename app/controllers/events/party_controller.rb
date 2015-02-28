#encoding:utf-8
class Events::PartyController < ApplicationController
  layout "tradev"

  def index
    if @user
      @supplier=Ecstore::Supplier.find(params[:supplier_id])
      render :layout => "default"    
    end

  end

  def stepone
    @users=Ecstore::User.where(:member_id=>@user.member_id).first
     if @users.update_attributes(params[:user])

     end
    redirect_to "/events/party?supplier_id=78&step=2"
  end

  def steptwo
    @event = Imodec::Event.new(params[:event]) do |ev|
       ev.startime= Time.parse(params[:event][:startime]).to_i
       ev.endtime= Time.parse(params[:event][:endtime]).to_i
    end

     if @event.save
       redirect_to "/events/party?supplier_id=78&step=3"
     end
   end

  def list
    @supplier=Ecstore::Supplier.find(params[:supplier_id])
    @events  = Imodec::Event.paginate(:page => params[:page], :per_page => 20,:order=>"endtime desc")
  end

  def user_party
    @supplier=Ecstore::Supplier.find(params[:supplier_id])
    @events  = Imodec::Event.paginate(:page => params[:page], :per_page => 20,:order=>"endtime desc",:conditions =>{
        :terminal=>"mobile",:member_id=>@user.member_id})
  end


  def detail
    @supplier=Ecstore::Supplier.find(params[:supplier_id])
    @event = Imodec::Event.find(params[:id])
    @applicants = @event.applicants.paginate(:page => params[:page], :per_page => 20,:order=>"created_at desc")
    @event_desc=@event.name
    #塞浦路斯
    if params[:id]=='8'
      render :layout=>"cyprus"
    end
  end

end