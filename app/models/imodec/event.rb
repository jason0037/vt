#encoding:utf-8
class Imodec::Event < ActiveRecord::Base
  attr_accessible :body, :name ,:startime ,:endtime  ,:adds,:terminal , :member_id

  belongs_to :ecstore_member, :class_name => 'Ecstore::Member',:foreign_key=>"member_id"
  extend FriendlyId
  friendly_id :name, :use => :slugged
  require "babosa"

  validates_presence_of :name,:message=>"活动名称不能为空"
  validates_presence_of :body,:message=>"活动内容不能为空"

  def normalize_friendly_id(input)
    input.to_s.to_slug.normalize().to_s
  end

  has_many :applicants

  def terminal_text
    return "电脑端" if self.terminal=="pc"
    return "手机端" if self.terminal=="mobile"

  end


end
