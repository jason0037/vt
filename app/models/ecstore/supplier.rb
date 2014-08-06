class Ecstore::Supplier < Ecstore::Base
	self.table_name = "sdb_imodec_suppliers"
	self.accessible_all_columns
  attr_accessor :license
 # attr_accessible :mobile,:email,:name,:sex, :ar

  has_many :goods, :foreign_key=>"supplier_id"
  belongs_to :user, :foreign_key=>"member_id"
end