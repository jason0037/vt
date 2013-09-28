class Ecstore::TagName < Ecstore::Base
	self.table_name = "sdb_desktop_tag"

	has_many :tags,:foreign_key=>"tag_id"

	has_many 	:goods,
				:through=>:tags

	has_one :tag_ext,:foreign_key=>"tag_id"

	def newest?
		@newest = Ecstore::TagName.where('tag_name rlike ?','z[0-9]{4}').last
		self == @newest
	end

  def newin?
    @newest = Ecstore::TagName.where('tag_name rlike ?','z[0-9]{4}').last
    self == @newest
  end

end