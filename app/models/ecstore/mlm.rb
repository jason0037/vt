class Ecstore::Mlm < Ecstore::Base
	self.table_name = 'multi_level_marketing'

	accessible_all_columns

  	belongs_to :user,:foreign_key=>"member_id"
  	belongs_to :member,:foreign_key=>"superior_id"
end