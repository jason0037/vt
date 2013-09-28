#encoding:utf-8
class Ecstore::Label < Ecstore::Base
	self.table_name = "sdb_imodec_labels"

	attr_accessible :name

	validates_presence_of :name,:message=>"名称不能为空"
end