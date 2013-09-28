#encoding:utf-8
class Ecstore::Card < Ecstore::Base
	self.table_name = "sdb_imodec_cards"
  	attr_accessible :buyer_tel, :card_type, :no, :sale_status, :status, :pay_status, :use_status, :user_tel, :value, :password,:sold_at,:used_at,:try_password_times
  	
  	has_one :member_card, :foreign_key=>"card_id"

  	has_many :card_logs,:foreign_key=>"card_id"

  	has_many :labelables,:foreign_key=>"labelable_id",:conditions=>{ :labelable_type=>"Ecstore::Card" }
  	
  	has_many :labels,:through=>:labelables
  	
  	def sold!
  		return if self.new_record?
  		self.update_attribute :sale_status, true
  	end

       def locked?
          self.status == '锁定'
       end

       def usable?
          return true if self.status == '正常'
          return false if self.status == '作废'
       end

       def can_buy?
           !self.sale_status && !locked? && self.usable?
       end

       def can_use?
            self.sale_status && self.usable? && !locked? && pay_status
       end

       def used?
           self.use_status
       end

       def normal?
          self.status == "正常"
       end

       scope :sold_cards_of, lambda { |buyer_id| joins(:member_card).where("sdb_imodec_member_cards.buyer_id = ? and sale_status = ?",buyer_id,true) }

       scope :unactive_cards_of, lambda { |user_tel| joins(:member_card).where("sdb_imodec_member_cards.user_tel = ? and use_status = ? and card_type= ? and pay_status = ?",user_tel,false,"A",true) }

       scope :activated_cards_of, lambda { |user_tel| joins(:member_card).where("sdb_imodec_member_cards.user_tel = ? and use_status = ?",user_tel,true) }
end