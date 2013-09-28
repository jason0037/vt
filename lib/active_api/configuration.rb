module ActiveApi
	class Configuration
		attr_accessor :site, :api_site, :client_id, :client_secret, :redirect_uri,:ssl,:authorize_uri,:access_token_uri,:path_prefix,:uid
	end
end