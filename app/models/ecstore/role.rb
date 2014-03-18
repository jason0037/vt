#encoding:utf-8
class Ecstore::Role < Ecstore::Base
  self.table_name = "sdb_desktop_roles"
  self.primary_key = 'role_id'
  self.accessible_all_columns

  has_many :hasrole, :foreign_key=>"role_id"

end