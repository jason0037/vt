class Ecstore::MemberAttr < Ecstore::Base
	self.table_name = "sdb_dbeav_meta_register"
	has_many :member_attr_values,:foreign_key=>"mr_id"

	def self.[](col_name)
		member_attr = self.where(:col_name=>col_name.to_s).first
		raise "column col_name `#{col_name}` is not exists in Table `sdb_dbeav_meta_register,please add it.`" unless member_attr
		member_attr
	end
end