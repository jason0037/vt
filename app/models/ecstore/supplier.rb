class Ecstore::Supplier < Ecstore::Base
	self.table_name = "sdb_imodec_suppliers"
	self.accessible_all_columns

  has_many :goods, :foreign_key=>"supplier_id"
end