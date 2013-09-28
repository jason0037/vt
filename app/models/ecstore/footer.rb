#encoding:utf-8
class Ecstore::Footer < Ecstore::AbstractPage

	attr_accessible :title, :body
	validates_presence_of :title, message: "标题不能为空"
	validates_presence_of :body, message: "内容不能为空"

	def self.common_footer
		first.body if first
	end
end