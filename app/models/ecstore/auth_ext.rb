class Ecstore::AuthExt < Ecstore::Base
	self.table_name = "sdb_pam_auth_ext"
	belongs_to :account,:foreign_key=>"account_id"

	attr_accessible :account_id,:access_token,:expires_at,:expires_in,:uid,:provider

	def expired?
		expires_at < Time.now.to_i
	end
end