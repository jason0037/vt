#encoding:utf-8
namespace :imodec do
	task :config=>:environment do
		Ecstore::Config.where(:key=>"page_title").first_or_initialize(:name=>"网站Title",:value=>"摩登客 | 体验个性摩登生活方式,尊享服装配饰设计品牌精品").save
		Ecstore::Config.where(:key=>"meta_keywords").first_or_initialize(:name=>"网站Keywords",:value=>"时尚服饰,设计师服装,时尚女性服饰,女装,配饰").save
		Ecstore::Config.where(:key=>"meta_description").first_or_initialize(:name=>"网站Description",:value=>"摩登客汇聚全球设计师服装精品，打造都市时尚女性首选个性网络衣橱。").save
	end
end