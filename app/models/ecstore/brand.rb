#encoding:utf-8
class Ecstore::Brand < Ecstore::Base

	include Ecstore::Metable

	extend FriendlyId
	friendly_id :slug

	self.table_name = "sdb_b2c_brand"
	self.primary_key = 'brand_id'
	has_many :goods, :foreign_key=>"brand_id",:conditions=>{:marketable=>'true'}
	has_one :brand_page

	has_one :seo, :foreign_key=>:pk,:conditions=>{ :mr_id => 3 }

	has_many :addresses, :as=>:addressable

	accepts_nested_attributes_for :addresses, :allow_destroy=>true
	attr_accessible :addresses_attributes

	has_one :offline_coupon


	default_scope where(:disabled=>'false')

	
	# attr_accessible :brand_id,:slug, :brand_desc, :status,:brand_name
	self.accessible_all_columns
	

	scope :menu_brands, order("ordernum asc,slug asc")


	validates_presence_of :brand_name,:message=>"品牌名称不能为空"
	validates_presence_of :slug,:message=>"访问地址不能为空"
	validates_uniqueness_of :slug,:message=>"您输入的访问地址已经存在"


	def logo_url
		if File.exists?("#{Rails.root}/public/pic/logos/#{self.brand_name.strip}.png")
			"/pic/logos/#{self.brand_name.strip}.png"
		else
			nil
		end
	end

	def list_logo
		if File.exists?("#{Rails.root}/public/pic/brands/#{self.slug}.gif")
			"/pic/logos/#{self.slug}.gif"
		else
			nil
		end
	end
end