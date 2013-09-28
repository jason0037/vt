#encoding:utf-8
class Ecstore::SpecValue < Ecstore::Base
	self.table_name = "sdb_b2c_spec_values"
	
	belongs_to :spec,:foreign_key=>"spec_id"

	belongs_to :image, :foreign_key=>"spec_image"

	# self.primary_key = "spec_value_id"

	self.accessible_all_columns


	def abbr
		return self.alias.downcase if self.alias.present?
		spec_value.split(/\s+/).last.downcase
	end

	def css_name_of_spec_value
		case self.spec_value
			when  I18n.t("product.spec.semi_custom")
				'semi_custom'
			when I18n.t("product.spec.full_custom")
				'custom'
			else
				return 'average' if self.spec_value.downcase.include?('均码')
				return 'xxs' if self.spec_value.downcase.include?('xxs')
				return 'xs' if self.spec_value.downcase.include?('xs')
				return 's' if self.spec_value.downcase.include?('s')
				return 's' if self.spec_value.downcase.include?('s')
				return 'm' if self.spec_value.downcase.include?('m')
				return 'l' if self.spec_value.downcase.include?('l')
				return 'xl' if self.spec_value.downcase.include?('xl')
				return 'xxl' if self.spec_value.downcase.include?('xxl')
		end
	end
end