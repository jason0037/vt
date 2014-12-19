class Ecstore::Visitor< Ecstore::Base

  attr_accessible :visitor_name, :visitor_password, :address, :tel, :phone, :postal ,:shop_id


  def gen_shop_secret_string_for_cookie

    md5_login_name = Digest::MD5.hexdigest(self.visitor_name)
    md5_password = Digest::MD5.hexdigest(self.visitor_password)
    "#{self.id}-#{md5_login_name}-#{md5_password}-#{Time.now.to_i}-#{self.shop_id}"
  end


end

