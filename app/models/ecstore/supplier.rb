class Ecstore::Supplier < Ecstore::Base
  #include WeixinRailsMiddleware::AutoGenerateWeixinTokenSecretKey
	self.table_name = "sdb_imodec_suppliers"
	self.accessible_all_columns
  attr_accessor :license
 # attr_accessible :mobile,:email,:name,:sex, :ar

  has_many :goods, :foreign_key=>"supplier_id"
  has_many :pages
  belongs_to :user, :foreign_key=>"member_id"
  has_many :orderdining ,:foreign_key=>"supplier_id"
  has_many :homes ,:foreign_key=>"supplier_id"
  end
