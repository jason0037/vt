#encoding:utf-8
module Admin::BrandPagesHelper
	def brand_status_options(selected=nil)
		brand_statuses.collect do |key,txt|
			if selected == key.to_s
				"<option value='#{key}' selected>#{txt}</option>"
			else
				"<option value='#{key}'>#{txt}</option>"
			end
		end.join("").html_safe
	end

	def brand_statuses
		{:new=>"新进品牌",:normal=>"正常",:special=>"重点突出(热门)",:coming=>"coming soon",:disabled=>"暂不合作"}
	end
end
