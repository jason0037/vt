#encoding:utf-8
class Ecstore::Advert < Ecstore::Base
  self.table_name = "sdb_cheuks_adverts"


  attr_accessible :title, :advert_slug, :body,:cat_id

  validates_presence_of :title, message: "标题不能为空"
  validates_presence_of :body, message: "内容不能为空"
  validates_presence_of :advert_slug,message: "广告地址不能为空"



  include Ecstore::Metable

  end