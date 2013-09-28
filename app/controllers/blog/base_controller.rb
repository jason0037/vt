class Blog::BaseController < ActionController::Base
	protect_from_forgery
	include SessionsHelper
	layout 'blog'


end