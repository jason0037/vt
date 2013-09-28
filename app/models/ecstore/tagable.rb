class Ecstore::Tagable < Ecstore::Base
	self.table_name = "sdb_desktop_tag_rel"
	self.accessible_all_columns

	belongs_to :teg, :foreign_key=>"tag_id"

	belongs_to :good, :foreign_key=>"rel_id", :conditions=> ["sdb_desktop_tag_rel.tag_type = ?","goods"]
	belongs_to :order, :foreign_key=>"rel_id", :conditions=>  ["sdb_desktop_tag_rel.tag_type = ?","orders"]
	belongs_to :user, :foreign_key=>"rel_id", :conditions=>  ["sdb_desktop_tag_rel.tag_type = ?","members"]
	
end