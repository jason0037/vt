#encoding:utf-8
include ActionView::Helpers::SanitizeHelper
namespace :imodec do
	task :seo=>:environment do

		# ======migrate brands seo=======
		Ecstore::Brand.unscoped.all.each do |brand|
			if brand.meta_seo
				brand.meta_seo.update_attributes(:title=>"#{brand.brand_name} | 摩登客 | 体验个性摩登生活方式,尊享服装配饰设计品牌精品",
									    :keywords =>brand.seo&&brand.seo.keywords,
									    :description =>brand.seo&&brand.seo.description)

				puts "=============updating brand `#{brand.brand_name}` ok============="
			else
				brand.create_meta_seo(:title=>"#{brand.brand_name} | 摩登客 | 体验个性摩登生活方式,尊享服装配饰设计品牌精品",
									    :keywords =>brand.seo&&brand.seo.keywords,
									    :description =>brand.seo&&brand.seo.description)
				puts "=============migrating brand `#{brand.brand_name}` ok============="
			end
		end

		# ======migrate cats seo=======
		Ecstore::Category.all.each do |cat|

			if cat.meta_seo
				cat.meta_seo.update_attributes(:title=>"#{cat.cat_name} | 摩登客 | 体验个性摩登生活方式,尊享服装配饰设计品牌精品",
									    :keywords =>cat.seo&&cat.seo.keywords,
									    :description =>cat.seo&&cat.seo.description)

				puts "=============updating cat `#{cat.cat_name}` ok============="
				
			else
				cat.create_meta_seo(:title=>"#{cat.cat_name} | 摩登客 | 体验个性摩登生活方式,尊享服装配饰设计品牌精品",
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
			title << "摩登客"
			title << "体验个性摩登生活方式,尊享服装配饰设计品牌精品"

			keywords = [] 
			keywords << good.name
			keywords << good.brand.brand_name if good.brand
			keywords << good.cat.cat_name if good.cat
			keywords << "摩登客"

		      description = []
		      description << "摩登客2013最新当季时尚优雅设计师品牌"
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