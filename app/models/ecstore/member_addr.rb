#encoding:utf-8
class Ecstore::MemberAddr < Ecstore::Base
	self.table_name = 'sdb_b2c_member_addrs'

	belongs_to :user, :foreign_key=>"member_id"

	attr_accessible :province, :city, :district, :addr, :zip, :name, :mobile, :tel, :def_addr, :member_id ,:addr_type

	def addr_line
		result = ""
		result += self.area.to_s.split(":")[1].gsub("/","-") if self.area.present?
		"#{result} #{self.addr} (收货人 : #{self.name}, 手机 : #{self.mobile}, 邮编 : #{self.zip})"
	end

	def display_area
		self.area.split(":")[1]
	end


	validates_presence_of :addr, :message=>"请填写收货地址"
	validates_presence_of :name, :message=>"请填写收货人姓名"

	validates :mobile,:presence=>{ :presence=>true,:message=>"请填写手机号码" }
	validates :mobile,:format=>{ :with=>/^\d{11}$/,:message=>"手机号码必须是11位数字" },
					    :if=>Proc.new{ |c| c.mobile.present? }



      validate :check_area
      def check_area
      		if province.blank? || city.blank?
      		    self.errors.add(:area, "请选择送货地区")
      		else
      			if Ecstore::Region.find_by_region_id(city).subregions.size > 0
      				self.errors.add(:area, "请选择送货地区") if district.blank?
      			end
      		end
      end

	before_save :make_area

	def make_area
		_province = Ecstore::Region.find_by_region_id(province)
		_city = Ecstore::Region.find_by_region_id(city)
		_district = Ecstore::Region.find_by_region_id(district)

		if _province && _city
			self.area = "mainland:#{_province.local_name}/#{_city.local_name}:#{_city.region_id}"
		end

		if _province && _city && _district
			self.area = "mainland:#{_province.local_name}/#{_city.local_name}/#{_district.local_name}:#{_district.region_id}"
		end

	end

	after_save :update_member_def_addr

	def update_member_def_addr
		Ecstore::MemberAddr.where("member_id = ? and addr_id <> ? ",self.member_id,self.addr_id).update_all(:def_addr=>0) if self.def_addr
	end

	def def_addr?
		self.def_addr
	end

	def province
		@province ? @province : parsed_region_ids[0]
	end

	def province=(val)
		@province = val
	end

	def city
		@city ? @city : parsed_region_ids[1]
	end

	def city=(val)
		@city = val
	end

	def district
		@district ? @district : parsed_region_ids[2]
	end

	def district=(val)
		@district = val
	end


	#  Return array #=> [ province_id , city_id, region_id ]
	def parsed_region_ids
	     region_id  = self.area.split(":").last.to_i if self.area
	     return [nil,nil,nil]  if region_id == 0 || new_record?
	     region = Ecstore::Region.find_by_region_id(region_id)
	     region.region_path.split(',').select{ |x| x.present? }
  	end
end