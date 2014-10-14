class Ecstore::Manager < Ecstore::Base
	self.table_name = "sdb_desktop_users"
  attr_accessible :user_id, :status, :name

  belongs_to :user,:foreign_key=>"user_id"
	has_one :account,:foreign_key=>"account_id"

  has_many :order, :foreign_key=>"desktop_user_id"
  has_many :hasrole, :foreign_key=>"user_id"


  has_one :permission,:foreign_key=>"manager_id",:class_name=>"Imodec::Permission"
	def super?
		self.super=="1"
	end
	def has_right_of(controller=nil,action=nil)
		return true if self.super=="1"
		return false unless self.permission
		rights = ActiveSupport::JSON.decode(self.permission.rights)

		if action.nil?
			return rights[controller.to_s]&&rights[controller.to_s].select{|k,v| v == "1"}.size > 0
		else
			if ctrl = rights[controller.to_s]
				if action.index(".")
					return rights[controller.to_s][action.to_s] == "1"
				else
					return ctrl.select do |act,val|
						act.split(".").include?(action) &&  val == "1"
					end.size > 0
				end
			else
				return false
			end
		end
	end

end