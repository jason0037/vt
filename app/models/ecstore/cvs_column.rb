class Ecstore::CvsColumn
	def initialize
		@columns = []
	end
	def parseModel(cols)
		cols.each_index do |i|
			name_value = cols[i].split(":")
			item = {:cheuksgroup=>i,:key=>name_value[0],:name=>name_value[1]}
			@columns.push item
		end
	end
	def columns
		return @columns
	end

	def index(row_name)
		@columns.each do |col|
			if col[:name] == row_name
				return col[:cheuksgroup]
			end
		end
		nil
	end
end