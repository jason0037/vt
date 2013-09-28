#encoding:utf-8
class Ecstore::GoodType < Ecstore::Base
  self.table_name = "sdb_b2c_goods_type"
  has_many :good_type_specs,:foreign_key=>"type_id"
  has_many :goods, :foreign_key=>"type_id"

  def is_physical_value
  	if self.is_physical == "1"
  		return "是"
  	else
  		return "否"
  	end
  end
  def spec

  end
end
