class Ecstore::CardLog < Ecstore::Base
	self.table_name = "sdb_imodec_card_logs"
  	attr_accessible :card_id, :member_id, :message, :created_at
  	
  	belongs_to :card, :foreign_key=>"card_id"

  	belongs_to :account,:foreign_key=>"member_id"

end