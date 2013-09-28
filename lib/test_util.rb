#encoding:utf-8
require "pp"
def serialize(o)
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
def deserialize(s)
	
end
# pp serialize({:name=>"hello",:age=>12,:sex=>nil,:hobby=>['play',{:game=>'eud',:fddf=>'wew'}],:other=>"无敌"})

# pp serialize([])
# a,b,c = "i:10".split(":",3)
# pp a,b,c
#pp "i:10".split(":",3)

# pp deserialize("i:10");
# pp deserialize("s:2:\"ok\"");

# pp "i:1;s:2:\"ok\"".split(/[;:]/,3)
# pp "s:8:\"goods_id\";s:3:\"639\";".split(/[;:]/,4)

# pp "a:4:{s:8:\"goods_id\";s:3:\"639\";s:10:\"product_id\";s:4:\"1623\";s:7:\"adjunct\";a:0:{}s:14:\"extends_params\";N;}".split(/[;{}]/)
# pp "N;".split(/[;:}]/,3)
# pp "i:1;s:2:\"ok\";s:8:\"goods_id\";s:3:\"639\";s:10:\"product_id\";s:4:\"1623\";s:7:\"adjunct\";a:0:{}s:14:\"extends_params\";N;".split(/[;:}]/,4)



# pp "a:3:{s:10:\"spec_value\";a:2:{i:1;s:14:\"蓝色系 Blue\";i:2;s:1:\"M\";}s:21:\"spec_private_value_id\";a:2:{i:1;s:13:\"1348224274613\";i:2;s:13:\"1348224274614\";}s:13:\"spec_value_id\";a:2:{i:1;s:1:\"7\";i:2;s:2:\"79\";}}".split(/[;{}]/)


a = "a:2:{i:1;a:1:{i:1348239130124;a:5:{s:13:\"spec_value_id\";s:1:\"9\";s:10:\"spec_value\";s:14:\"灰色系 Gray\";s:21:\"private_spec_value_id\";s:13:\"1348239130124\";s:10:\"spec_image\";s:32:\"00fe387c1340e16e994aa15ef5c81ef1\";s:17:\"spec_goods_images\";s:0:\"\";}}i:2;a:1:{i:1348239130125;a:5:{s:13:\"spec_value_id\";s:2:\"60\";s:10:\"spec_value\";s:10:\"165/88A(L)\";s:21:\"private_spec_value_id\";s:13:\"1348239130125\";s:10:\"spec_image\";s:0:\"\";s:17:\"spec_goods_images\";s:0:\"\";}}}".split(/[;{}]/)
# pp a
# arr = a.clone

# a.each_with_index do |e,i|
# 	if e[0] == 'a'
# 		arr[i] = "["
# 	elsif e == ""
# 		arr[i] = "]"
# 	else
# 		arr[i] = deserialize(e)
# 	end
# end


# r = arr.inject("") do |memo,e|
# 	if e =="["
# 		memo += e.to_s
# 	else
# 		memo += "#{e},"
# 	end
# end

# h = Hash[eval(r+"]]]")]
# pp h
b = "a:2:{i:1;a:1:{i:1348239130124;a:5:{s:13:\"spec_value_id\";s:1:\"9\";s:10:\"spec_value\";s:14:\"灰色系 Gray\";s:21:\"private_spec_value_id\";s:13:\"1348239130124\";s:10:\"spec_image\";s:32:\"00fe387c1340e16e994aa15ef5c81ef1\";s:17:\"spec_goods_images\";s:0:\"\";}}i:2;a:1:{i:1348239130125;a:5:{s:13:\"spec_value_id\";s:2:\"60\";s:10:\"spec_value\";s:10:\"165/88A(L)\";s:21:\"private_spec_value_id\";s:13:\"1348239130125\";s:10:\"spec_image\";s:0:\"\";s:17:\"spec_goods_images\";s:0:\"\";}}}"

b = "a:0:{}"
# b = "s:2:\"9\";";
# b = "N;"
 
 # str  =  b.gsub(/a\:[0-9]+\:/,'').gsub(/i\:([0-9]+)\;/) {|s| "#{$1},"}.gsub(/[{}]/,'{'=>'[','}'=>'],').gsub(/s\:[0-9]+\:(\"[^"]*\")\;/){ |s| "#{$1}," }
 
str =  b.gsub(/s\:[0-9]+\:(\"[^"]*\")\;/){ |s| "#{$1}," }.gsub(/i\:([0-9]+)\;/){ |s| "#{$1}," }.gsub(/a\:[0-9]+\:/,'').gsub(/[{}]/,'{'=>'[','}'=>'],').gsub("N;","nil,")
str  =  str[0..-2]
pp eval(str)




# h = h.map{ |k,v| v = eval("Hash#{v}") if v.is_a?(Array)}

# def des(hash)
# 	result = {}
# 	hash.each do |k,v|
		
# 		if v.is_a?(Array) && v.size % 2 ==0
# 			 v = eval("Hash#{v}")
# 		end	

# 		result[k] = v
	
# 	end
# 	result
# end

class Array
	def deep_to_hash
		arr = map do |v|
			v.is_a?(Array) && v.size % 2 == 0 ? v.deep_to_hash : v 
		end
		eval("Hash#{arr}")
	end
end

# puts  eval(str[0..-2]).deep_to_hash




# h = h.map do |k,v|
# 	if v.is_a?(Array) && v.size%2 == 0
# 		v = eval("Hash#{v}")
# 	end
# end
# pp h
# hash = Hash.new {  |h,k|  h[k] = Hash[h[v]] }
# h.each do |k,v|
# 	pp eval"Hash#{v}"
# end

# while arr.size>0

# end
