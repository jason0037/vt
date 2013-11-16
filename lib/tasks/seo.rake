#encoding:utf-8
include ActionView::Helpers::SanitizeHelper
namespace :imodec do
	task :seo=>:environment do

		# ======migrate brands seo=======
		Ecstore::Brand.unscoped.all.each do |brand|
			if brand.meta_seo
				brand.meta_seo.update_attributes(:title=>"#{brand.brand_name} | TRADE-V | 跨境贸易，一键直达",
									    :keywords =>brand.seo&&brand.seo.keywords,
									    :description =>brand.seo&&brand.seo.description)

				puts "=============updating brand `#{brand.brand_name}` ok============="
			else
				brand.create_meta_seo(:title=>"#{brand.brand_name} | TRADE-V | 跨境贸易，一键直达",
									    :keywords =>brand.seo&&brand.seo.keywords,
									    :description =>brand.seo&&brand.seo.description)
				puts "=============migrating brand `#{brand.brand_name}` ok============="
			end
		end

		# ======migrate cats seo=======
		Ecstore::Category.all.each do |cat|

			if cat.meta_seo
				cat.meta_seo.update_attributes(:title=>"#{cat.cat_name} | TRADE-V | 跨境贸易，一键直达",
									    :keywords =>cat.seo&&cat.seo.keywords,
									    :description =>cat.seo&&cat.seo.description)

				puts "=============updating cat `#{cat.cat_name}` ok============="
				
			else
				cat.create_meta_seo(:title=>"#{cat.cat_name} | TRADE-V | 跨境贸易，一键直达",
									    :keywords =>cat.seo&&cat.seo.keywords,
									    :description =>cat.seo&&cat.seo.description)
				puts "=============migrating cat `#{cat.cat_name}` ok============="
			end
		end


		# ======migrate goods seo=======
		Ecstore::Good.all.each do |good|
			title = []
			title << good.name 
			title << good.brand.brand_name if good.brand
			title << good.cat.cat_name if good.cat
			title << "TRADE-V"
			title << "TRADE-V | 跨境贸易，一键直达"

			keywords = [] 
			keywords << good.name
			keywords << good.brand.brand_name if good.brand
			keywords << good.cat.cat_name if good.cat
			keywords << "TRADE-V"

		      description = []
		      description << "TRADE-V | 跨境贸易，一键直达"
		      description << strip_tags(good.desc) if good.desc.present?


			if good.meta_seo
				

				good.meta_seo.update_attributes(:title=>title.join(" | "),
									    :keywords =>keywords.join(","),
									    :description =>description.join(","))

				puts "=============updating good `#{good.name}` ok============="
				
			else
				good.create_meta_seo(:title=>title.join(" | "),
									    :keywords =>keywords.join(","),
									    :description =>description.join(","))

				puts "=============updating good `#{good.name}` ok============="
			end
		end

	end
end