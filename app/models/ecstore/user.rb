#encoding:utf-8
class Ecstore::User < Ecstore::Base
  self.table_name = "sdb_b2c_members"
  self.primary_key = 'member_id'

  attr_accessor :province,:city,:district
  attr_accessible :mobile,:email,:name,:sex, :area,:addr, :b_year, :b_month, :b_day, :bank_info,
                            :interests,:voc, :job, :income, :height, :weight, :shoesize,:price,:places,:colors,:edu,
                            :province,:city,:district,:login_count,:sms_validate,:email_validate,:custom_values,:sent_sms_at,:wechat_num,:user_desc
  self.accessible_all_columns
  has_one :mlm, :foreign_key=>"member_id"

  belongs_to :account,:foreign_key=>"member_id"

  has_many :line_items,:class_name=>"Cart",:foreign_key=>"member_id",:conditions=>{ :obj_type=>"goods" }

  has_many :custom_specs,:class_name=>"CustomValue",:foreign_key=>"member_id"
  
  has_many :suppliers, :foreign_key=>"member_id"

  has_many :member_coupons, :foreign_key=>"member_id"

  has_many :reccommend_logs, :foreign_key=>"member_id"

  has_many :member_attr_values,:class_name=>"MemberAttrValue",:foreign_key=>"pk"#,:before_add=>:check_member_attr_value_update
  
  has_many :member_advances, :foreign_key=>"member_id"

  has_many :member_addrs, :foreign_key=>"member_id"

  has_many :user_coupons, :foreign_key=>"member_id"

  has_many :orders, :foreign_key=>"member_id"

  has_many :inventorys, :foreign_key=>"member_id"

  has_many :inventory_log, :foreign_key=>"member_id"

  has_many :favorites, :foreign_key=>"member_id", :conditions=> { :type=>"fav" }

  belongs_to :member_lv,:foreign_key=>"member_lv_id"

  has_many :tagables, :foreign_key=>"rel_id"
  has_many :tegs, :through=>:tagables

  has_many :hasrole, :foreign_key=>"user_id"
  has_many :manager,:foreign_key=>"user_id"
  has_many :shops,:foreign_key=>"member_id"
  has_many :shop_clients,:foreign_key=>"member_id"
  has_many :imodec_events, :class_name => 'Imodec::Event'  , :foreign_key=>"member_id"
  has_many :imodec_applicants, :class_name => 'Imodec::applicants'  , :foreign_key=>"member_id"

  def aftersale_orders
      self.orders.includes(:order_logs).joins(:order_logs).where("behavior = ?  and  result = ? and alttime >= ? and status = ? ","finish","SUCCESS",(Time.now - 7.days).to_i,"finish")
  end

  # def usable_coupons
  #   self.member_coupons.where(:disabled=>'false',:memc_source=>'b',:memc_used_times=>0).to_a +
  #   self.member_coupons.where(:disabled=>'false',:memc_source=>'a').to_a
  # end

  def usable_coupons
      user_coupons.select{ |user_coupon| user_coupon.can_use? }
  end

  def member_attr_value(col_name)
  	member_attr_values.where(:mr_id=>Ecstore::MemberAttr[col_name].mr_id).first
  end

  def check_member_attr_value_update(member_attr_val)

  	if member_attr_values.where(:mr_id=>member_attr_val.mr_id).first
  		member_attr_values.where(:mr_id=>member_attr_val.mr_id)[0].value = member_attr_val.value
  	end
  end

  [:job,:income,:height,:weight,:shoesize,:price,:places,:colors,:edu,:interests,:voc].each do |ext_attr|
  	class_eval <<-ATTR_EVAL,__FILE__,__LINE__+1
  		def #{ext_attr}=(val)
                  return member_attr_values.where(:mr_id=>Ecstore::MemberAttr['#{ext_attr}'].mr_id).delete_all unless val.present?
  			val = val.join(',') if val.is_a?(Array)
  			return if v = member_attr_value('#{ext_attr}') and v.value == val
  			member_attr_values.where(:mr_id=>v.mr_id).delete_all if v
  			member_attr_values.build(:mr_id=>Ecstore::MemberAttr['#{ext_attr}'].mr_id,:value=>val)
  		end

  		def #{ext_attr}
  			val = member_attr_value('#{ext_attr}')
                   if val
                      return val.value.split(",") if '#{ext_attr}'.end_with?('s')
                      return val.value
                   else
                      return [] if '#{ext_attr}'.end_with?('s')
                   end
  		end
  	ATTR_EVAL
  end

  # def interests=(interests)
  #     if interests
  # 	   self.interest = interests.join(",")
  #     else
  #        self.interest = nil
  #     end
  # end

  # def interests
  #     return [] if self.interest.nil?
  # 	self.interest.split(",") if self.interest
  # end

  def gift
    mrid = Ecstore::MemberAttr['giftfornewuser'].mr_id
    member_attr = member_attr_values.where(:mr_id=>mrid,:pk=>self.member_id)
    return member_attr[0].value if !member_attr[0].nil?
  end

  def province=(p)
    @province = p if p.present?
  end

  def province
    @province ||= parsed_region_ids[0]
  end

  def city=(c)
    @city = c if c.present?
  end

  def city
    @city ||= parsed_region_ids[1]
  end

  def district=(d)
    @district = d if d.present?
  end

  def district
    @district ||= parsed_region_ids[2]
  end

  def sex_text
    return "男" if sex == '1'
    return "女" if sex == '0'
    return "未知" if sex == '2'
  end

  def birthday
    birth = ""
    birth += "#{b_year}后 " if b_day.to_i > 0
    birth += "#{b_month}月" if b_month.to_i > 0
    birth += "#{b_day}日" if b_day.to_i > 0
    return "未填写" if birth.blank?
    birth
  end

  def province_text
     p = Ecstore::Region.find_by_region_id(province)
     p.local_name if p
  end

  def city_text
     c = Ecstore::Region.find_by_region_id(city)
     c.local_name if c
  end

  def district_text
     d = Ecstore::Region.find_by_region_id(district)
     d.local_name if d
  end

  def parsed_region_ids
     region_id  = self.area.split(":").last if self.area
     return [nil,nil,nil]  if region_id.nil? || region_id.to_i == 0
     region = Ecstore::Region.find_by_region_id(region_id.to_i)
     region.region_path.split(',').select{|x| x.present?}
  end

  def mask_email
    return if self.email.blank?
     _email = self.email.clone
     _email[1...(_email.index('@')-1)] = "****"
     _email 
  end

  def mask_mobile
    return "未填写" if self.mobile.blank?
     _mobile = self.mobile.clone
     _mobile[3..7] = "*****"
     _mobile 
  end

  def first_login?
     self.login_count <= 1
  end

  validates_presence_of :mobile,:message=>"请输入您的手机号码"

  validate :check_email_duplicated,:check_mobile_duplicated

  def check_mobile_duplicated
    if self.mobile.present? and u = Ecstore::User.find_by_mobile(self.mobile) and  u != self
      errors.add(:mobile, "手机号码已经被使用！")
    end
  end

  def check_email_duplicated
    if self.email.present? and u = Ecstore::User.find_by_email(self.email) and  u != self
      errors.add(:email, "邮箱已经被使用！")
    end
  end

 def receive_register_gift(val)
  	member_attr = Ecstore::MemberAttr.where(:tbl_name=>"sdb_b2c_members",
	 	      								:pk_name=>"member_id",
	 	      								:col_name=>"giftfornewuser").first
	 	      			

	member_attr_values = Ecstore::MemberAttrValue.where(:mr_id=>member_attr.mr_id,
													:pk=>self.member_id)
	Ecstore::MemberAttrValue.create(:mr_id=>member_attr.mr_id,
							    :pk=>self.member_id,
							    :value=>val)  unless member_attr_values.count>0
 end

 def has_received_gift?
 	member_attr = Ecstore::MemberAttr.where(:tbl_name=>"sdb_b2c_members",
	 	      										  :pk_name=>"member_id",
	 	      										  :col_name=>"giftfornewuser").first
 	return false unless member_attr
 	return true if Ecstore::MemberAttrValue.where(:mr_id=>member_attr.mr_id,:pk=>self.member_id).first
 	return false
 end

 def receive_coupon
 	#generate coupon
	coupon = Ecstore::Coupon.where(:cpns_prefix=>"B0001",:cpns_status=>"1").first
	coupon_code = coupon.make_coupon_code if coupon

	return if Ecstore::MemberCoupon.where(:member_id=>self.member_id,:memc_code=>coupon_code).size > 0
	
	#add coupon to user
      memc = Ecstore::MemberCoupon.new do |mc|
		mc.memc_code = coupon_code
		mc.cpns_id =  coupon.cpns_id
		mc.member_id = self.member_id
		mc.memc_source = coupon.cpns_type == "1" ? "b" : (coupon.cpns_type == "0" ? "a" : "c")
		mc.memc_enabled  = "true"
		mc.memc_gen_time = Time.now.to_i
		mc.disabled = "false"
		mc.memc_isvalid = "true"
	end.save if coupon

	coupon.increment!(:cpns_gen_quantity) if memc
 end

 def receive_new_coupon
    coupon = Ecstore::NewCoupon.where(:coupon_prefix=>"B0001").first
    coupon_code = coupon.generate_coupon_code(true)
    
    return if Ecstore::UserCoupon.where(:member_id=>self.member_id,:coupon_code=>coupon_code).present?

    Ecstore::UserCoupon.new do |uc|
      uc.member_id = self.member_id
      uc.coupon_id = coupon.id
      uc.coupon_code = coupon_code
    end.save
 end
  
 before_save :update_validate
 
 def update_validate
    return if new_record?
    u = Ecstore::User.find_by_member_id(self.member_id)
    self.sms_validate = 'false'  if u.mobile!=self.mobile && u.sms_validate == 'true'
    self.email_validate = 'false' if u.email != self.email && u.email_validate == 'true'
 end


 def cart_total
    self.line_items.select{|x| x.product.present? }.collect{ |x| (x.product.price*x.quantity).to_i }.inject(:+)
 end

 def cart_total_quantity
    total = 0
    self.line_items.select{|x| x.product.present? }.each do |line_item|
       total += line_item.quantity.to_i
    end

    total
 end

 def send_reset_password_instruction(email_or_mobile)
    if email_or_mobile.to_s == "email"
      return send_reset_password_email
    end
    if email_or_mobile.to_s == "mobile"
      return send_reset_password_sms
    end
 end

 def send_reset_password_email
    self.reset_password_token = self.class.generate_reset_password_token
    self.reset_password_sent_at = Time.now
    save(:validate=>false)
    begin
      ResetPasswordMailer.reset_password_email(self).deliver
      return true
    rescue
      errors.add :send_reset_password_instruction, "发送重设密码邮件失败"
      return false
    end
 end


 def custom_value_of(spec_item_id)
    return nil  if self.custom_values.blank?
    
    tmp = ActiveSupport::JSON.decode(self.custom_values).select do |h|
          h["spec_item_id"].to_s == spec_item_id.to_s
    end.first
    tmp&&tmp["value"]
 end

 def sms_validated?
    self.mobile.present?&&self.sms_validate == 'true'
 end

 def email_validated?
    self.email.present? && self.email_validate == 'true'
 end

 def login_name
   self.account&&self.account.login_name
 end

  def check_sms(sms_code)
    return false if sms_code.blank?
    if self.sms_code == sms_code && ( self.sent_sms_at + 60*30 > Time.now ) 
            self.update_attribute :sms_code,nil
            return true
    else
      return false
    end
 end

 def send_reset_password_instruction(email_or_mobile)
    if email_or_mobile.to_s == "email"
      return send_reset_password_email
    end
    if email_or_mobile.to_s == "mobile"
      return send_reset_password_sms
    end
 end

 def send_reset_password_email
    self.reset_password_token = self.class.generate_reset_password_token
    self.reset_password_sent_at = Time.now
    save(:validate=>false)
    begin
      ResetPasswordMailer.reset_password_email(self).deliver
      return true
    rescue
      errors.add :send_reset_password_instruction, "发送重设密码邮件失败"
      return false
    end
 end

 def send_reset_password_sms
    sms_code = self.class.generate_sms_token
    self.reset_password_token = sms_code
    self.reset_password_sent_at = Time.now
    save(:validate=>false)
    template = Ecstore::Config.get(:reset_password_sms_template)
    text = template.gsub('#{code}',sms_code)
    
    begin
      if Sms.send(self.mobile,text)
        return true
      else
         errors.add :send_reset_password_instruction, "发送手机验证码失败"
         return false
      end
    rescue
        errors.add :send_reset_password_instruction, "发送手机验证码错误"
        return false
    end
 end
 
 def reset_password_token_expired?
    return true if self.reset_password_sent_at.blank?
    self.reset_password_sent_at  + 2.hours < Time.now
 end

 def clear_reset_password_token
    self.reset_password_token = nil
    self.reset_password_sent_at = nil
    save(:validate => false)
 end


 
 def self.generate_reset_password_token
    SecureRandom.urlsafe_base64(15)
 end
 
 def self.generate_sms_token
    (0..5).map { rand(10) }.join
 end

end
