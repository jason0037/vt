
 class Ecstore::Express < Ecstore::Base
   self.table_name ="sdb_b2c_expresses"
  attr_accessible :arrival, :departure, :total, :unit_price



   def self.serachall (departure,arrival)
     sql="select * from sdb_b2c_expresses where departure=? and arrival=?",departure,arrival;
     Ecstore::Express.find_by_sql(sql);
   end

   end
