require "utils/serializable"
require "utils/serialize"
require "utils/deserialize"

module Utils
	def self.serialize(o)
		case o.class.to_s
			when "String","Symbol"
				"s:#{o.to_s.each_byte.to_a.size}:\"#{o}\";"
			when "Fixnum","Bignum"
				"i:#{o};"
			when "NilClass"
				"N;"
			when "Hash"
				"a:#{o.size}:{#{o.collect{|k,v| serialize(k)+serialize(v) }.join('')}}"
			when "Array"
				serialize Hash[(1..o.size).to_a.zip(o)]
			else
				nil
		end
	end
end