#encoding:utf-8
module Admin::GoodsHelper
	def expandable?(spec_value)
		spec_value == I18n.t("product.spec.semi_custom")
	end

	def softness_options
		{"1"=>1,
		 "2"=>2,
		 "3"=>3,
		 "4"=>4,
		 "5"=>5
		}
	end

	def thickness_options
		{"1"=>1,
		 "2"=>2,
		 "3"=>3,
		 "4"=>4,
		 "5"=>5
		}
	end

	def elasticity_options
		{"1"=>1,
		 "2"=>2,
		 "3"=>3,
		 "4"=>4,
		 "5"=>5
		}
	end

	def fitness_options
		{"1"=>1,
		 "2"=>2,
		 "3"=>3,
		 "4"=>4,
		 "5"=>5
		}
	end

end
