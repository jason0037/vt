#encoding:utf-8
class Ecstore::DesktopUser < Ecstore::Base
  self.table_name = "sdb_desktop_users"
  self.primary_key = 'user_id'
  self.accessible_all_columns

  belongs_to :account,:foreign_key=>"account_id"

  has_many :order, :foreign_key=>"desktop_user_id"
  has_many :desktop_hasrole, :foreign_key=>"user_id"


end