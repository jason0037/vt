class Imodec::Resource < ActiveRecord::Base
  attr_accessible :name, :description,:parent_id
  
  has_many :actions, :class_name=>"Imodec::Resource",:foreign_key=>"parent_id"

  belongs_to :controller,:class_name=>"Imodec::Resource"

  class << self

  	def goods_resources
  		ctrls =  %w(suppliers goods goods_types goods_cats specifications brand_adms tag_exts)
  		where(:name=>ctrls).order("FIELD(name,#{ctrls.map{|e| "'#{e}'" }.join(',') })")
  	end

  	def order_resources
            ctrls = %w(orders tags emails)
            where(:name=>ctrls).order("FIELD(name,#{ctrls.map{|e| "'#{e}'" }.join(',') })")
  	end

  	def user_resources
            ctrls = %w(members promotions new_coupons user_coupons cards)
            where(:name=>ctrls).order("FIELD(name,#{ctrls.map{|e| "'#{e}'" }.join(',') })")
  	end

  	def article_resources
            ctrls = %w(articles topics events homes static_pages footers brand_pages metas)
            where(:name=>ctrls).order("FIELD(name,#{ctrls.map{|e| "'#{e}'" }.join(',') })")
  	end

  	def system_resources
             ctrls = %w(configs wechat)
  		where(:name=>ctrls).order("FIELD(name,#{ctrls.map{|e| "'#{e}'" }.join(',') })")
    end

  end

end
