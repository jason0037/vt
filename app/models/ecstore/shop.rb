#encoding:utf-8
class Ecstore::Shop< Ecstore::Base

  attr_accessible :shop_id, :shop_name, :shop_tel, :shop_email, :shop_logo, :shop_wx, :shop_intro, :shop_publish

  end


def good_status_text
  return  '上架' if good_status=='1'
  return  '下架' if good_status=='0'
end
