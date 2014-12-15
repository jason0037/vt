class Ecstore::Visitor< Ecstore::Base

  attr_accessible :visitor_name, :visitor_password, :address, :tel, :phone, :postal ,:shop_id

  validates :visitor_name, :presence=>{:presence=>true,:message=>"请填写用户名"}

  end

