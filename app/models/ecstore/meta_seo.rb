#encoding:utf-8
class Ecstore::MetaSeo < Ecstore::Base
	self.table_name = "sdb_imodec_seo"
	
	self.accessible_all_columns

	serialize :params, Hash

	belongs_to :metable, :polymorphic=>true


	scope :path_metas, where(:metable_type=>"path")

	validates_presence_of :path, :message=>"访问路径不能为空", :if=>"metable_type=='path'"

	def params=(arr=[])
		hash = {} 
		arr.each do |kv|
			hash.merge! Hash.send :[], *kv.values
		end
		super(hash)
	end

	def params_text
		params.collect { |key,val| "#{key}=#{val}"}.join("&")
	end


end


