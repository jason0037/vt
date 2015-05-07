class Ecstore::Category < Ecstore::Base
      
	self.table_name = "sdb_b2c_goods_cat"
	self.primary_key = 'cat_id'
  # attr_accessible :p_order 
  # self.accessible_all_columns
  
	has_many :goods, 
				:foreign_key=> "cat_id",
				:conditions=>{:marketable=>'true'}

	has_many :categories,:foreign_key=>"parent_id",:class_name=>"Category"
 	belongs_to :parent_cat,  :foreign_key=>"parent_id", :class_name=>"Category"

  has_one :seo, :foreign_key=>:pk,:conditions=>{ :mr_id => 4 }

  include Ecstore::Metable

	def cat_paths(include_self=true)
     cat_ids = cat_path_ids
     cat_ids << self.cat_id.to_s if include_self
     Ecstore::Category.where(:cat_id=>cat_ids)
	end

  def cat_path_ids
      self.cat_path.split(",").select{ |x| x.present? }
  end

  def full_path_name
        self.cat_paths.collect { |cat| cat.cat_name }.join(" -> ")
  end

  	# Conditions must be a hash for filter goods
  	# and must be field of Ecstore::Good
  	#== example
  	#  cat.all_goods(:brand_id=>1)
  	#  cat.all_goods(:cat_id=>1)
  	#  
  	def all_goods( conditions={} )
  		@all_goods = []
  		
  		conditions.each do |key,val|
  			raise "Field `#{key}`  is existence" unless Ecstore::Good.attribute_names.include?(key.to_s)
  		end if conditions.present?

  		if self.categories.blank?
  			@all_goods += self.goods.where(conditions).order("d_order desc").to_a 
  		else
  			self.categories.each { |cat| @all_goods += cat.all_goods(conditions) }
  		end

  		@all_goods

  	end

  	
  	def self.apparel_menus
  		self.find_by_cat_id(22).categories.order("p_order asc").limit(8).select { |cat| cat.all_goods.size > 0}
  	end

      # 根据分类链获取分类信息
      # === example
      # Category.get_cat_by_names_chain("时装 Apparel -> 上衣 Blouses") #=> [ category, catgory ]
      def self.get_cat_by_names_chain(names_chain)
        cat_names = names_chain.split("->").map{ |x| x.strip }
        return nil  if cat_names.blank?

        cat_path = []

        loop do
          cat_name = cat_names.pop
          cats = self.where(:cat_name=>cat_name)

          if cat_names.size == 0
            cat_path << cats.first
            break
          end

          if cats.size == 1
            cat_path << cats.first
          else
            if cats.collect { |cat| cat.parent_cat.cat_name }.flatten.include?(cat_names.last)
              cat_path << cats.first
            end
          end

        end
        cat_path
      end

	class << self
		def refresh_goods_cat_count
			Category.all.each do |cat|
				goods=cat.goods
				if goods && goods.count > 0
					cat.update_attribute :goods_count, goods.count
				else
					cat.update_attribute :goods_count, nil
				end
			end

			Category.all.each do |category|
				subcates = category.categories
				if subcates.count > 0
					total = subcates.inject(0) do |mem,c|
						mem+=( c.goods_count || 0 )
					end
					category.update_attribute :goods_count, total if total > 0
				end
			end

		end
	end
end