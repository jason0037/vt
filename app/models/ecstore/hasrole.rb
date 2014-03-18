#encoding:utf-8
class Ecstore::Hasrole < Ecstore::Base
  self.table_name = "sdb_desktop_hasrole"
  self.accessible_all_columns

  belongs_to :role,:foreign_key=>"role_id"
  belongs_to :manager,:foreign_key=>"user_id"
  belongs_to :user,:foreign_key=>"user_id"

  scope :sales,where(:role_id=>17)
end