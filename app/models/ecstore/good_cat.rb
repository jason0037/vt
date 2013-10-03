class Ecstore::GoodCat < Ecstore::Base
  self.table_name = "sdb_b2c_goods_cat"
  attr_accessible :cat_name, :cat_id, :type_id

  def child_cats
  	childs = Ecstore::GoodCat.where(:parent_id=>self.cat_id)
  end

  def self.top_cats
    cats = Ecstore::GoodCat.where(:parent_id=>0)
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
