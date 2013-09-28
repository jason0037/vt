#encoding:utf-8
class Imodec::Event < ActiveRecord::Base
  attr_accessible :body, :name

  extend FriendlyId
  friendly_id :name, :use => :slugged
  require "babosa"

  validates_presence_of :name,:message=>"活动名称不能为空"
  validates_presence_of :body,:message=>"活动内容不能为空"

  def normalize_friendly_id(input)
    input.to_s.to_slug.normalize().to_s
  end

  has_many :applicants

end
