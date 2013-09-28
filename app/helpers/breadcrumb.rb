module Breadcrumb
	module ClassMethods
		def add_breadcrumb(name,path=nil)

			@breadcrumbs = {}  unless @breadcrumbs
			@breadcrumbs.merge!(name=>path)
		end

		def breadcrumbs
			@breadcrumbs || {}
		end

		def clear_breadcrumbs
			@breadcrumbs = {}
		end
	end
	
	module InstanceMethods
		def add_breadcrumb(name,path=nil)
			self.class.add_breadcrumb(name,path)
		end

		def breadcrumbs

			self.class.breadcrumbs
		end

		def clear_breadcrumbs
			self.class.clear_breadcrumbs
		end

	end


	# module HelperMethods
	# 	def render_breadcrumbs
	# 		breadcrumbs
	# 	end
	# end
	
	def self.included(controller)
		controller.extend         ClassMethods
		controller.send :include, InstanceMethods
		# receiver.helper HelperMethods
		controller.helper_method  :breadcrumbs
	end
end