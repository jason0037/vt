#encoding:utf-8
class Ecstore::VirtualGood < Ecstore::Base
	self.table_name = "sdb_imodec_virtual_goods"

	belongs_to :brand
	belongs_to :cat, :class_name=>"Category",:foreign_key=>"cat_id"

	include Ecstore::Metable

	extend FriendlyId
	friendly_id :slug

	self.accessible_all_columns


	validates_presence_of :name, :message=>"名称不能为空"
	validates_presence_of :price, :message=>"价格不能为空"
	validates :price, :numericality =>{ :greater_than_or_equal_to=>0,:message=>"价格必须大于等于0的数字"},
	                             :if => :price

	before_save :set_marketing_time,:set_slug

	def set_marketing_time
		if self.changes[:marketable].present?
			if self.marketable
				self.uptime = Time.now.to_i  
			else
              self.downtime = Time.now.to_i  
			end
		end
	end

	def set_slug
		self.slug = self.bn if self.bn.present?
	end

	def up_at
		Time.at(uptime).strftime("%Y-%m-%d %H:%M:%S") if uptime.present?
	end

	def down_at
		Time.at(downtime).strftime("%Y-%m-%d %H:%M:%S") if downtime.present?
	end

	def pictures(style=:large,format=:jpg)
		pattern  = "#{Rails.root}/public/pic/vgoods/#{self.bn}/#{style}/*.#{format}"
	   Dir.glob(pattern).collect do  |file| 
	       "/pic/vgoods/#{self.bn}/#{style}/#{File.basename(file)}"
	   end.sort
	end

	def self.import(csv_file,options={:encoding=>"GB18030:UTF-8"})
		begin
			rows = CSV.read(csv_file,options)
		rescue Exception => e
			return "读取文件错误, #{e}, 请检查文件格式"
		end

		header = rows.shift

		if rows.size == 0
			return "没有足够数据，请检查文件"
		end

		bn_index  = header.index("col:商品编号")
		cat_index  = header.index("col:分类")
		brand_index  = header.index("col:品牌")
		price_index  = header.index("col:市场价")
		name_index  = header.index("col:商品名称")
		marketable_index  = header.index("col:上架")
		desc_index  = header.index("col:商品描述")

		title_index  = header.index("col:page_title")
		keywords_index  = header.index("col:meta_keywords")
		description_index  = header.index("col:meta_description")

		# validate data
		errors = {}
		rows.each_with_index do |row,index|
			
			row_error = []


			bn = row[bn_index] if bn_index
			row_error << "商品编号为空"  if bn.blank?
			row_error << "商品编号已经存在" if bn.present? && Ecstore::VirtualGood.find_by_bn(bn)


			price = row[price_index] if price_index
			row_error << "商品价格为空" if price.blank?
			row_error << "商品价格不是数字"  if price.present? && !price =~ /^\d+.?\d+$/

			name = row[name_index] if name_index
			row_error << "商品名称为空" if name.blank?

			cats_chain  = row[cat_index] if cat_index
			row_error << "商品分类为空" if cats_chain.blank?

			if cats_chain.present?
				cat_names = cats_chain.split("->").map{ |x| x.strip }
				
				loop do
					cat_name = cat_names.pop
					cats  = Ecstore::Category.where(:cat_name=>cat_name)
					if cats.size == 0
						row_error << "商品分类不存在"
						break
					else cats.size > 1
						if cat_names.size >= 1&&cats.select{ |cat| cat.parent_cat&&cat.parent_cat.cat_name == cat_names[-1] }.size == 0
							row_error << "商品分类错误"
							break
						end
					end
					break if cat_names.blank?
				end
			end

			brand_name = row[brand_index] if brand_index
			row_error << "品牌为空" if brand_name.blank?
			row_error << "品牌不存在" if brand_name.present? && !Ecstore::Brand.find_by_brand_name(brand_name)


			errors[index+2]  = row_error if row_error.present?
		end

		return errors  if errors.present?

       # import data
		rows.each do |row|
			Ecstore::VirtualGood.new do |vgood|
				vgood.bn = row[bn_index]
				vgood.price = row[price_index].to_i
				vgood.name = row[name_index]
				vgood.marketable = row[marketable_index] == "Y" ? true : false
				vgood.desc = row[desc_index]
				
				_cats = Ecstore::Category.get_cat_by_names_chain(row[cat_index])
				vgood.cat_id = _cats.first.cat_id if _cats && _cats.first

				vgood.brand_id = Ecstore::Brand.find_by_brand_name(row[brand_index]).brand_id
				vgood.meta_seo = Ecstore::MetaSeo.new(:title=>row[title_index],
					                                                                      :keywords=>row[keywords_index],
					                                                                      :description=>row[description_index])
			end.save
		end

		return "导入成功, 导入商品#{rows.size}件!"
	end

end