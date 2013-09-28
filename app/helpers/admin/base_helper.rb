module Admin::BaseHelper
  
  def method_missing(method,*args)
    	if /(.*)_with_subdomain$/ =~ method
    		subdomain = args.pop[:subdomain]
    		path = Rails.application.routes.url_helpers.send($1,args)
    		"http://#{subdomain}.#{request.domain}:#{request.server_port}#{path}"
    	else
    		super
    	end
    	
  end

end
