class Ecstore::BlackGood < Ecstore::Base

  self.table_name = "sdb_b2c_black_good"
  attr_accessible :cat_id, :downtime, :from_area,  :name, :price, :receive, :ship_area, :ship_id, :status, :type_id, :uptime, :weight,:desc




  belongs_to :cat,:class_name=>"Category",:foreign_key=>"cat_id"
  belongs_to :good_type, :foreign_key=>"type_id"
  belongs_to :user,:foreign_key=>"ship_id"
  belongs_to :user,:foreign_key=>"receive"     ###接单人



end
