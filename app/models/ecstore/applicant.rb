#encoding:utf-8
class Ecstore::Applicant < Ecstore::Base
  self.table_name = "sdb_imodec_applicants"
  attr_accessible :age, :email, :mobile, :name, :sex

  validates_presence_of :name,:message=>"请填写姓名"
  validates_presence_of :mobile,:message=>"请填写手机"
  validates_presence_of :email,:message=>"请填写邮箱"
  
end
