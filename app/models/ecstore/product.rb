#encoding:utf-8
class Ecstore::Product < Ecstore::Base
	self.table_name  = "sdb_b2c_products"

	belongs_to :good, :foreign_key=>"goods_id"
	has_many :custom_values,:foreign_key=>"product_id"
	has_many :good_specs,:foreign_key=>"product_id"
	has_many :spec_values, :through=>:good_specs

	self.accessible_all_columns

	


	def brand
		self.good.brand
	end

	def cat
		self.good.cat
	end

	def color
		return nil unless self.spec_desc.is_a?(Hash)
		spec_value_id  = self.spec_desc["spec_value_id"][1]
		specv = Ecstore::SpecValue.find(spec_value_id)
		return specv.alias.downcase if specv.alias.present?
		return specv.spec_value.split(/\s+/).last.downcase
	end

	def color_id
		return nil unless self.spec_desc.is_a?(Hash)
		spec_value_id  = self.spec_desc["spec_value_id"][1]
	end

	def size
		return nil unless self.spec_desc.is_a?(Hash)
		spec_value_id  = self.spec_desc["spec_value_id"].except(1).values.first
		specv = Ecstore::SpecValue.find(spec_value_id)
		specv.spec_value.strip
	end

	def size_id
		return nil unless self.spec_desc.is_a?(Hash)
		spec_value_id  = self.spec_desc["spec_value_id"].except(1).values.first
	end

	def custom_spec_values_of(user)
		
		if user.is_a?(Ecstore::User)
			member_id =  user.member_id
		else
			member_id =  user.to_i
		end

		groups = self.custom_values.where(:member_id=>member_id,:order_id=>nil).pluck(:ident).uniq
		
		groups.collect do |ident|
			self.custom_values.where(  :member_id=>member_id,
										:order_id=>nil,
										:ident=> ident ).collect do |cv|
				"#{cv.name} : #{cv.value}"
			end.join(", ")
		end
	end

	def pictures(style,format='jpg')
		# return []  if self.color.blank?
		# pattern  = "#{Rails.root}/public/pic/product/#{self.good.bn}/#{style}/#{self.color}/*.#{format}"
		# Dir.glob(pattern).collect do  |file| 
	 #          "/pic/product/#{self.good.bn}/#{style}/#{self.color}/#{File.basename(file)}"
		# end.sort{|x,y| y<=>x}
		return [] if self.big_pic.blank?

	    pics = self.big_pic.split("|")

	    return pics
	end

	def list_pictures(format='jpg')
		pattern  = "#{Rails.root}/public/pic/product/#{self.good.bn}/list/*.#{format}"
		Dir.glob(pattern).collect do  |file| 
	          "/pic/product/#{self.good.bn}/list/#{File.basename(file)}"
		end.sort{|x,y| y<=>x}
	end

	def custom_picture
		"/pic/product/#{self.good.bn}/#{custom}/#{self.color}/color.jpg}"
	end


	def full_custom?
		self.spec_info.include? I18n.t("product.spec.full_custom")
	end

	def semi_custom?
		self.spec_info.include? I18n.t("product.spec.semi_custom")
	end

	def spec_desc
     		# super.deserialize
  	end

  	def sold_out?
  		self.store.to_i - self.freez.to_i <= 0
  	end

  	def p_store
  		store.to_i - freez.to_i
  	end

  	def gift_image_url
	    img = Ecstore::Image.find_by_image_id self.good.image_default_id
	    "http://www.i-modec.com/#{img.s_url}"
	end
end