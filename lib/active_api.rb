require 'active_support'
require 'hashie'
require 'faraday'
require 'json'
require 'active_api/provider'
require 'active_api/connection'
require 'active_api/configuration'

module ActiveApi
	class << self
		def register(name,&blk)
			@providers = {}  if @providers.nil?
		      provider = Object.const_set(name.to_s.camelize,Class.new(Provider))
		      @providers[name] = provider
		      provider.instance_eval &blk
		end

		def providers
			@providers
		end
	end
end
