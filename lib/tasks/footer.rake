#encoding:utf-8
namespace :imodec do
	task :footer=>:environment do 
		ac = ActionController::Base.new
		@footer = Ecstore::Footer.first_or_initialize(:title=>"通用页脚",
										   :body=>ac.render_to_string(:partial=>"shared/footer",:layout=>false))
		@footer.save
	end
end