class Ecstore::Address < Ecstore::Base
	self.table_name = "sdb_imodec_addresses"
	belongs_to :brand, :polymorphic=>true

	self.accessible_all_columns

	geocoded_by :name
	after_validation :geocode

	def province
		self.name.slice(0,2)
	end
end