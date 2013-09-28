#encoding:utf-8
class Ecstore::SpecItem < Ecstore::Base
	self.table_name = 'sdb_b2c_spec_items'
	attr_accessible :name,:item_type

	has_many :good_spec_items, :foreign_key=>"spec_item_id",:dependent=>:destroy
	validates_presence_of :name,:message=>"名称不能为空 !"
end