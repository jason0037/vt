module ActiveApi
	class Base

		def initialize(&blk)
			self.instance_eval &blk
		end

		def authorize_url(*args)
			opts = args.extract_options!
			response_type =  opts.delete(:response_type)

  	params = {
				:response_type => response_type || 'code',
				:client_id => config.client_id,
				:redirect_uri=>config.redirect_uri
			}.merge!(opts)
			"#{config.authorize_uri}?#{params.to_query}"
    end

    def request_token_multi(code,appid,secret)
      params = {
          :client_id => appid,
          :client_secret => secret,
          :redirect_uri => config.redirect_uri,
          :grant_type=>'authorization_code',
          :code=>code
      }
      request_time = Time.now.to_i

      res = Faraday.new(config.access_token_uri,:ssl=>config.ssl, :params => params).post

      body = Hashie::Mash.new JSON.parse(res.body)
      body.merge! :expires_at=>(body.expires_in + request_time)
      body
    end

		def request_token(code)

			params = {
				:client_id => config.client_id,
				:client_secret => config.client_secret,
				:redirect_uri => config.redirect_uri,
				:grant_type=>'authorization_code',
				:code=>code
			}
			request_time = Time.now.to_i

			res = Faraday.new(config.access_token_uri,:ssl=>config.ssl, :params => params).post
			
			body = Hashie::Mash.new JSON.parse(res.body)
			body.merge! :expires_at=>(body.expires_in + request_time)
			body
		end

		def config
			@config ||= ActiveApi::Configuration.new
		end
	end
end