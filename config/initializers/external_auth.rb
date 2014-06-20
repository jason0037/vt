require 'active_api'
if Rails.env == 'development'
  ActiveApi.register :weixin do
    config.site = "https://open.weixin.qq.com/"
    config.api_site = "https://open.weixin.qq.com/"
    config.client_id = "wxec23a03bf5422635"
    config.client_secret =  "b57aa686db378f60fe5e3b80b3bb412c"
    config.redirect_uri = "http://www.trade-v.com/auth/weixin/callback"
    config.ssl = { :ca_path=>"/usr/lib/ssl/certs" }
    config.authorize_uri = 'https://open.weixin.qq.com/connect/oauth2/authorize'
    config.access_token_uri = 'https://api.weixin.qq.com/sns/oauth2/access_token'
    config.path_prefix = '2/'
    config.uid = 'gh_a0e5b9a22803'
    #https://open.weixin.qq.com/connect/oauth2/authorize?appid=APPID&redirect_uri=REDIRECT_URI&response_type=code&scope=SCOPE&state=STATE#wechat_redirect
  end
	ActiveApi.register :weibo do
		config.site = "https://api.weibo.com/"
		config.api_site = "https://api.weibo.com/"
		config.client_id = "4052702765" #"3753212031"
		config.client_secret =  "87381b5bd4d8a549781e03a7ab3d5ef2" #"c704909e5153beb073d4db8e2bd31a1c" #
		config.redirect_uri = "http://test2.i-modec.com/auth/weibo/callback"
		config.ssl = { :ca_path=>"/usr/lib/ssl/certs" }
		config.authorize_uri = 'https://api.weibo.com/oauth2/authorize'
		config.access_token_uri = 'https://api.weibo.com/oauth2/access_token'
		config.path_prefix = '2/'
		config.uid = '2398180552' #"1822088872" 
	end
	ActiveApi.register :douban do
		config.site = "https://api.douban.com/"
		config.api_site = "https://api.douban.com/"
		config.client_id = "02d7b2751350a19f0887175f39f1e4dd"
		config.client_secret = "d3d9bb7216bf4386"
		config.redirect_uri = "http://test2.i-modec.com/auth/douban/callback"
		config.ssl = { :ca_path=>"/usr/lib/ssl/certs" }
		config.authorize_uri = 'https://www.douban.com/service/auth2/auth'
		config.access_token_uri = 'https://www.douban.com/service/auth2/token'
		config.path_prefix = 'v2/'
		config.uid = '66643961'
	end
end
if Rails.env == 'production'
  ActiveApi.register :weixin do
    config.site = "https://open.weixin.qq.com/"
    config.api_site = "https://open.weixin.qq.com/"
    config.client_id = "wxec23a03bf5422635"
    config.client_secret =  "b57aa686db378f60fe5e3b80b3bb412c"
    config.redirect_uri = "http://www.trade-v.com/auth/weixin/callback"
    config.ssl = { :ca_path=>"/usr/lib/ssl/certs" }
    config.authorize_uri = 'https://open.weixin.qq.com/connect/oauth2/authorize'
    config.access_token_uri = 'https://open.weixin.qq.com/connect/oauth2/access_token'
    config.path_prefix = '2/'
    config.uid = 'gh_a0e5b9a22803'
    #https://open.weixin.qq.com/connect/oauth2/authorize?appid=APPID&redirect_uri=REDIRECT_URI&response_type=code&scope=SCOPE&state=STATE#wechat_redirect
  end
	ActiveApi.register :weibo do
		config.site = "https://api.weibo.com/"
		config.api_site = "https://api.weibo.com/"
		config.client_id = "288643931"
		config.client_secret = "e8257964e79451f15e742a9d95d379c7"
		config.redirect_uri = "http://www.i-modec.com/auth/weibo/callback"
		config.ssl = { :ca_path=>"/usr/lib/ssl/certs" }
		config.authorize_uri = 'https://api.weibo.com/oauth2/authorize'
		config.access_token_uri = 'https://api.weibo.com/oauth2/access_token'
		config.path_prefix = '2/'
		config.uid = '2398180552'
	end
	ActiveApi.register :douban do
		config.site = "https://api.douban.com/"
		config.api_site = "https://api.douban.com/"
		config.client_id = "02d7b2751350a19f0887175f39f1e4dd"
		config.client_secret = "d3d9bb7216bf4386"
		config.redirect_uri = "http://www.i-modec.com/auth/douban/callback"
		config.ssl = { :ca_path=>"/usr/lib/ssl/certs" }
		config.authorize_uri = 'https://www.douban.com/service/auth2/auth'
		config.access_token_uri = 'https://www.douban.com/service/auth2/token'
		config.path_prefix = 'v2/'
		config.uid = '66643961'
	end
end

