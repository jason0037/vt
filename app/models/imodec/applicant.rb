#encoding:utf-8
class Imodec::Applicant < ActiveRecord::Base
  attr_accessible :age, :email, :mobile, :name, :sex,:event_id ,:wechat_num ,:member_id,:user_desc
  belongs_to :ecstore_member, :class_name => 'Ecstore::Member',:foreign_key=>"member_id"
  validates_presence_of :name,:message=>"请填写姓名"
  # validates_presence_of :age,:message=>"请填写年龄"
  validates :age,:numericality => { :only_integer => true,:message=>"年龄必须是数字" },:if=>Proc.new{ |c| c.age.present? }

  # validates :email,:presence=>{:presence=>true,:message=>"请填写邮箱"}
  # validates :email,:format=>{:with=>/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i,:message=>"邮箱格式不正确"},
		# 			    :if=>Proc.new{ |c| c.email.present? }

  validates :mobile,:presence=>{:presence=>true,:message=>"请填写手机号码"}

  validates :mobile,:format=>{:with=>/^\d{11}$/,:message=>"手机号码必须是11位数字"},
					    :if=>Proc.new{ |c| c.mobile.present? }

  belongs_to :event
  
end