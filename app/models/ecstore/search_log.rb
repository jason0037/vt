class Ecstore::SearchLog < Ecstore::Base
	self.table_name = "sdb_b2c_search_log"


	self.accessible_all_columns

	belongs_to :user,:foreign_key=>"member_id",:class_name=>"User"

end