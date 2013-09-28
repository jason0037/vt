class Ecstore::Tag < Ecstore::Base
	self.table_name = "sdb_desktop_tag_rel"
	self.primary_key = 'rel_id'
	belongs_to :tag_name,:foreign_key=>"tag_id"
	belongs_to :good,
				:foreign_key=>"rel_id"

	def getTagName
		tag =Ecstore::Tag.where(:rel_id=>self.rel_id,:tag_type=>"members").first
		if tag.nil?
			return ""
		end
		if tag.tag_id !=0
			tagName = Ecstore::TagName.find(tag.tag_id)
			return tagName.tag_name
		else
			return ""
		end
	end

	

end