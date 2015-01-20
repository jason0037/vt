#encoding:utf-8
class Ecstore::Shop< Ecstore::Base

  self.accessible_all_columns

  has_many :shop_clients, :foreign_key=>"shop_id"

  end


def good_status_text
  return  '上架' if good_status=='1'
  return  '下架' if good_status=='0'
end
