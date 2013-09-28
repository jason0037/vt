class Ecstore::MemberAttrValue < Ecstore::Base
	self.table_name = "sdb_dbeav_meta_value_varchar"

	attr_accessible :mr_id, :pk, :value

end