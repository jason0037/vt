namespace :imodec do
	desc "create resources"
	task :res=>:environment do
		require "pp"
		Imodec::Resource.connection.execute("truncate table #{Imodec::Resource.table_name}")
		
		res = YAML.load_file(File.expand_path("resources.yml",File.dirname(__FILE__)))
		
		res.each do |k,v|
			controller_desc=v.delete("desc")
			@controller = Imodec::Resource.where(:name=>k).first_or_initialize
			@controller.description = controller_desc

			v.each do |name,desc|
				action = Imodec::Resource.where(:name=>name,:parent_id=>@controller.id).first_or_initialize
				action.description = desc
				@controller.actions << action
			end

			@controller.save
		end

	end
end