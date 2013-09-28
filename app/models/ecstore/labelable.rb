class Ecstore::Labelable < Ecstore::Base
	self.table_name = "sdb_imodec_labelables"

	belongs_to :label, :foreign_key=>"label_id"
	belongs_to :card, :foreign_key=>"labelable_id",:conditions=>{ :labelable_type=>"Ecstore::Card" }
end