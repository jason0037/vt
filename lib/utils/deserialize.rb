class Array
	def deep_to_hash
		arr = map do |v|
			v.is_a?(Array) && v.size % 2 == 0 ? v.deep_to_hash : v 
		end
		eval("Hash#{arr}")
	end
end

class String
	def deserialize
		s  =  self.gsub(/s\:[0-9]+\:(\"[^"]*\")\;/){ |s| "#{$1}," }.gsub(/i\:([0-9]+)\;/){ |s| "#{$1}," }.gsub(/a\:[0-9]+\:/,'').gsub(/[{}]/,'{'=>'[','}'=>'],').gsub("N;","nil,")
		return self if s == self
		result = eval(s[0..-2])
		result.is_a?(Array) ? result.deep_to_hash : result
	end
end