#encoding:utf-8
class Ecstore::Teg < Ecstore::Base
	self.table_name = "sdb_desktop_tag"
	self.accessible_all_columns

	has_many :tagables,:foreign_key=>"tag_id"
	has_many :goods, :through=>:tagables
	has_one :tag_ext, :foreign_key=>"tag_id"

	scope :good_tegs, where(:tag_type=>"goods")
	scope :order_tegs, where(:tag_type=>"orders")
	scope :user_tegs, where(:tag_type=>"members")
	scope :member_tegs, where(:tag_type=>"members")

	validates_presence_of :tag_name,:message=>"标签名不能为空"
	validates :tag_name, :uniqueness => { :scope => :tag_type, :message => "同类标签不能重名" }



end