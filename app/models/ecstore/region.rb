#encoding:utf-8
class Ecstore::Region < Ecstore::Base
	self.table_name = "sdb_ectools_regions"
	default_scope order("region_id ASC")

	has_many :subregions,:class_name=>"Region",:foreign_key=>"p_region_id"

	belongs_to :province,:class_name=>"Region",:foreign_key=>"p_region_id",:conditions=>{:region_grade=>1}

	belongs_to :city,:class_name=>"Region",:foreign_key=>"p_region_id",:conditions=>{:region_grade=>2}

	scope :provinces,where(:p_region_id=>nil).order("region_id ASC")

	

	def self.cities_of(province)
		return province.subregions if province.is_a?(self) and province.region_grade == 1
		self.find_by_region_id(province).subregions
	end

	def self.districts_of(city)
		return city.subregions if city.is_a?(self) and city.region_grade == 2
		self.find_by_region_id(city).subregions
	end

	def cities
		self.subregions.order("region_id ASC") if self.region_grade == 1
	end

	def districts
		self.subregions.order("region_id ASC") if self.region_grade == 2
	end


	def self.hash_region
		Hash.new do |hash,key|
			hash[key] = Ecstore::Region.find_by_region_id(key).subregions.collect do |city|
				{:region_id=>city.region_id,:local_name=>city.local_name}
			end
		end
	end

	def self.hash_cities
		cities = self.hash_region
		self.provinces.each{ |p| cities[p.region_id] }
		cities
	end

	def self.hash_districts
		disctricts = self.hash_region
		self.provinces.collect{ |p| p.cities }.flatten.each{ |c| disctricts[c.region_id] }
		disctricts
	end

end