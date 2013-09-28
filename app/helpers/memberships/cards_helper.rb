#encoding:utf-8
module Memberships::CardsHelper
	def mask(string)
		return nil if string.nil?
		return string if string.length < 7
		dup_string = string.dup
		dup_string[3..6] = "****"
		dup_string
	end

	def level_hash(level)
		case level
			when "you"
				{:name=>"优摩卡",:value=>"10000"}
			when "chao"
				{:name=>"超摩卡",:value=>"20000"}
			when "ding"
				{:name=>"顶摩卡",:value=>"50000"}
		end
	end
end
