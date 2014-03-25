class Ecstore::GoodCat < Ecstore::Base
  self.table_name = "sdb_b2c_goods_cat"
  attr_accessible :cat_name, :cat_id, :type_id
  self.primary_key = 'cat_id'
  has_many :goods,
           :foreign_key=> "cat_id",
           :conditions=>{:marketable=>'true'}

  has_many :good_cats,:foreign_key=>"parent_id",:class_name=>"GoodCat"
  belongs_to :parent_cat,  :foreign_key=>"parent_id", :class_name=>"GoodCatgg"

  has_one :seo, :foreign_key=>:pk,:conditions=>{ :mr_id => 4 }

  include Ecstore::Metable

  def all_goods( conditions={} )
    @all_goods = []

    conditions.each do |key,val|
      raise "Field `#{key}`  is existence" unless Ecstore::Good.attribute_names.include?(key.to_s)
    end if conditions.present?

    if self.good_cats.blank?
      @all_goods += self.goods.where(conditions).order("d_order desc").to_a
    else
      self.good_cats.each { |cat| @all_goods += cat.all_goods(conditions) }
    end

    @all_goods

  end

  def child_cats
  	childs = Ecstore::GoodCat.where(:parent_id=>self.cat_id)
  end

  def self.top_cats
    cats = Ecstore::GoodCat.where(:parent_id=>0).where('sell=true or future=true or agent=true')
  end

  def start_blank
  	num = self.cat_path.split(",").length
  	str =""
  	num.times.each do 
  		str = str + "--"
  	end
  	return str
  end

  def cat_path_rep
  	return self.cat_path.gsub(",","-")
  end

  def cat_path_deep
  	num = self.cat_path.split(",").length
  end

  def has_leaf?
  	count = Ecstore::GoodCat.where(:parent_id=>self.cat_id).count
  	if count > 0
  		return true
  	else
  		return false
  	end
  end
end
