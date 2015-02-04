#encoding:utf-8
class Ecstore::Shop< Ecstore::Base
     ###status  1:是开启 0:是默认, -2是提交关闭 ,-1是关闭成功
  self.accessible_all_columns

  has_many :shop_clients, :foreign_key=>"shop_id"
  has_many :shop_log, :foreign_key=>"shop_id"
  belongs_to :user , :foreign_key=>"member_id"
  has_many :order, :foreign_key=>"shop_id"
  end


def good_status_text
  return  '上架' if good_status=='1'
  return  '下架' if good_status=='0'
end

def permission_branch_text
  return  '没有资格' if permission_branch=='-2'
  return  '具备申请' if permission_branch=='-1'
  return  '申请中' if permission_branch=='0'
  return  '批准' if permission_branch=='1'

end