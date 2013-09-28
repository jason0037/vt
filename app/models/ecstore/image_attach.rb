class Ecstore::ImageAttach < Ecstore::Base
  self.table_name = "sdb_image_image_attach"

  belongs_to :image
  belongs_to :good, :foreign_key=>"target_id"

end