require 'rubygems'
require 'sitemap_generator'

namespace :imodec do

	desc "generate site map"

	task :sitemap=>:environment do
		SitemapGenerator::Sitemap.default_host = 'http://www.i-modec.com'
		SitemapGenerator::Sitemap.public_path = '/data/httpd/mdk/public'
		SitemapGenerator::Sitemap.create_index = false
		SitemapGenerator::Sitemap.create do
		  add '/', :changefreq => 'daily', :priority => 0.9
		  add '/pages/aboutus', :changefreq => 'weekly'

		  Ecstore::Good.where(:marketable=>'true').find_each do |good|
		  	 add "/products/#{good.bn}", :changefreq=>'daily'
		  end

		  Ecstore::Brand.where(:disabled=>'false').find_each do |brand|
		  	if brand.slug
		  		add "/brands/#{brand.slug}",:changefreq=>'daily'
		  	else
		  		add "/brands/#{brand.brand_id}",:changefreq=>'daily'
		  	end
		  end

		  Ecstore::GoodCat.find_each do  |cat|
		  	add "/gallery/#{cat.cat_id}"
		  end

		  add "/topics", :host=>"http://blog.i-modec.com"
		  Imodec::Topic.where(:published=>true).each do |topic|
		  	if topic.slug
		  		add "/topic/#{topic.slug}", :host=>"http://blog.i-modec.com"
		  	else
		  		add "/topic/#{topic.id}", :host=>"http://blog.i-modec.com"
		  	end
		  end

		end
	end
end