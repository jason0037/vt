module ActiveApi
	module Http
		def self.included(base)
			base.send :include,InstanceMethods
		end

		module InstanceMethods

			def post(path,*args)
				params = args.extract_options!
				params.merge! :access_token=>self.access_token
				res = connection.post(path,params)
				Hashie::Mash.new JSON.parse(res.body)
			end

			def get(path,*args)
				params = args.extract_options!
				params.merge! :access_token=>self.access_token
				res = connection.get(path,params)
				Hashie::Mash.new JSON.parse(res.body)
			end
		end

		module ClassMethods
			def connection
				@conn ||= Faraday.new(:url => config.api_site,:ssl=>config.ssl) do |faraday|
				  faraday.request  :url_encoded
				  faraday.response :logger
				  faraday.adapter  Faraday.default_adapter
				  faraday.path_prefix =  config.path_prefix if config.path_prefix
				end
			end
		end
	end
end