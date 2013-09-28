
module ActiveApi
      class Provider
            attr_reader :access_token, :expires_in, :expires_at

            def initialize(*args)
	params = args.extract_options!
	@access_token = params[:access_token]
	@expires_at = params[:expires_at]
            end

            class << self
	def inherited(subclass)
	     subclass.send :include, Connection
	end

      	def config
                        @config ||= ActiveApi::Configuration.new
      	end
            end

      end
end