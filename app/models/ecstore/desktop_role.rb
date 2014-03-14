#encoding:utf-8
class Ecstore::DesktopRole < Ecstore::Base
  self.table_name = "sdb_desktop_roles"
  self.primary_key = 'role_id'
  self.accessible_all_columns

  has_many :desktop_hasrole, :foreign_key=>"role_id"

end