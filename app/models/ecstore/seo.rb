class Ecstore::Seo < Ecstore::Base

	warn 'warning : Ecstore::Seo is old seo model, please use Ectore::MetaSeo'

	self.table_name = 'sdb_dbeav_meta_value_longtext'
	attr_accessible :mr_id, :pk, :value

	[:title,:keywords,:description].each do |field|
		class_eval <<-EVAL, __FILE__, __LINE__+1
			def #{field}
				return nil if self.value.blank? || self.value.deserialize.blank?
				self.value.deserialize['seo_#{field}']  
			end
		EVAL
	end
end