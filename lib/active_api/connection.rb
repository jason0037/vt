module ActiveApi
	module Connection
		def self.included(receiver)
			receiver.extend         ClassMethods
			receiver.send :include, InstanceMethods
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

			def authorize_url(*args)
				opts = args.extract_options!
				response_type =  opts.delete(:response_type)
				params = {
					:response_type => response_type || 'code',
		#			:client_id => config.client_id,
          :appid => config.client_id,
					:redirect_uri=>config.redirect_uri,
          :scope => 'snsapi_userinfo',
          :state=> 'STATE#wechat_redirect'
				}.merge!(opts)
				"#{config.authorize_uri}?#{params.to_query}"
			end

  def request_token_multi(code,appid,secret)
      params = {
            :appid=> appid,
            :secret=> secret,
            :code=>code,
            :grant_type=>'authorization_code'
        }

        #https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
        request_time = Time.now.to_i
        res = Faraday.new(config.access_token_uri,:ssl=>config.ssl, :params => params).post
        #return  res.body
        body = Hashie::Mash.new JSON.parse(res.body)
        body.merge! :expires_at=>(body.expires_in + request_time)
        body
  end

			def request_token(code)
				params = {
		#			:client_id => config.client_id,
          :appid=> config.client_id,
					#:client_secret => config.client_secret,
          :secret=>config.client_secret,
					#:redirect_uri => config.redirect_uri,
          :code=>code,
					:grant_type=>'authorization_code'
				}
        #https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
				request_time = Time.now.to_i
				res = Faraday.new(config.access_token_uri,:ssl=>config.ssl, :params => params).post
        #return  res.body
				body = Hashie::Mash.new JSON.parse(res.body)
				body.merge! :expires_at=>(body.expires_in + request_time)
				body
			end
		end
		module InstanceMethods

			def post(path,*args)
				params = args.extract_options!
				params.merge! :access_token=>self.access_token
				res = self.class.connection.post(path,params)
				Hashie::Mash.new JSON.parse(res.body)
			end

			def get(path,*args)
				params = args.extract_options!
				params.merge! :access_token=>self.access_token
				res = self.class.connection.get(path,params)
				Hashie::Mash.new JSON.parse(res.body)
			end
		end
	end
end