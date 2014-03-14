#encoding:utf-8
class Ecstore::DesktopHasrole < Ecstore::Base
  self.table_name = "sdb_desktop_hasrole"
  self.accessible_all_columns

  belongs_to :desktop_role,:foreign_key=>"role_id"
  belongs_to :desktop_user,:foreign_key=>"user_id"

  scope :sales,where(:role_id=>17)
end