require 'active_support'
require 'hashie'
require 'faraday'
require 'json'
require 'pp'
require_relative 'active_api/provider'
require_relative 'active_api/configuration'


class Test < ActiveApi::Provider
	config.site = "https://api.weibo.com/"
	config.api_site = "https://api.weibo.com/"
	config.client_id = "4052702765" #"3753212031"
	config.client_secret = "87381b5bd4d8a549781e03a7ab3d5ef2" #"c704909e5153beb073d4db8e2bd31a1c" 
	config.redirect_uri = "http://test2.i-modec.com/auth/weibo/callback"
	config.ssl = { :ca_path=>"/usr/lib/ssl/certs" }
	config.authorize_uri = 'https://api.weibo.com/oauth2/authorize'
	config.access_token_uri = 'https://api.weibo.com/oauth2/access_token'
	config.path_prefix = '2/'
	config.uid = '2398180552'
end

pp Test.config




