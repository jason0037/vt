#encoding:utf-8
class Ecstore::Page < Ecstore::AbstractPage

	extend FriendlyId
	friendly_id :slug
	
	attr_accessible :title, :slug, :body, :layout,:supplier_id,:category

	validates_presence_of :title, message: "标题不能为空"
	validates_presence_of :body, message: "内容不能为空"
	validates_presence_of :slug,message: "访问地址不能为空"

  belongs_to  :supplier ,:foreign_key=>"supplier_id"

	include Ecstore::Metable
end