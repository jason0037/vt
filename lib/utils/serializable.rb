module Utils
	module Serializable
		def serialize
			o =  self
			case o.class.to_s
				when "String","Symbol"
					"s:#{o.to_s.each_byte.to_a.size}:\"#{o}\";"
				when "Fixnum","Bignum"
					"i:#{o};"
				when "NilClass"
					"N;"
				when "Hash"
					"a:#{o.size}:{#{o.collect{|k,v| k.serialize+v.serialize}.join('')}}"
				when "Array"
					Hash[(1..o.size).to_a.zip(o)].serialize
				else
					nil
			end
		end

		def serialize2
			o =  self
			case o.class.to_s
				when "String","Symbol"
					"s:#{o.to_s.each_byte.to_a.size}:\"#{o}\";"
				when "Fixnum","Bignum"
					"i:#{o};"
				when "NilClass"
					"N;"
				when "Hash"
					"a:#{o.size}:{#{o.collect{|k,v| k.serialize+v.serialize}.join('')}}"
				when "Array"
					Hash[(0..(o.size-1)).to_a.zip(o)].serialize
				else
					nil
			end
		end
	end
end