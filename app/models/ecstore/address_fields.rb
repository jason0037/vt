module Ecstore
	module AddressFields

		def province
			@province ? @province : parsed_region_ids[0]
			# @province.present? ? @province : parsed_region_ids[0]
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
		def parsed_region_ids(area_name = "ship_area")
		     area_val = self.send(area_name)
		     region_id  =area_val.split(":").last if area_val
		     return [nil,nil,nil]  if region_id.blank? || self.new_record?
		     region = Ecstore::Region.find_by_region_id(region_id)
		     region.region_path.split(',').select{ |x| x.present? }
	  	end

	  	def make_area
			_province = Ecstore::Region.find_by_region_id(province)
			_city = Ecstore::Region.find_by_region_id(city)
			_district = Ecstore::Region.find_by_region_id(district)

			if _province && _city
				self.ship_area = "mainland:#{_province.local_name}/#{_city.local_name}:#{city}"
			end

			if _province && _city && _district
				self.ship_area = "mainland:#{_province.local_name}/#{_city.local_name}/#{_district.local_name}:#{district}"
			end
		end
	end
end