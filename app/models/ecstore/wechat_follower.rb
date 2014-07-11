#encoding:utf-8
class Ecstore::WechatFollower < Ecstore::Base
	self.table_name  = 'sdb_wechat_followers'
	self.accessible_all_columns

  belongs_to :user,:foreign_key=>"member_id"

end