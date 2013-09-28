require 'digest/md5'
class Ecstore::Image < Ecstore::Base
  self.table_name = "sdb_image_image"
  default_scope where(:storage=>"filesystem")

  has_one :image_attach

end