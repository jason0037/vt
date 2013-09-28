#encoding : utf-8
class Imodec::Article < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, :use => :slugged
  require "babosa"

  # validates_presence_of :title, :slug, :body
  attr_accessible :body, :published, :title, :headlined, :summary, :cover, :remove_cover,:user_id
  has_attached_file :cover,
        :styles => { :cover => "215x140#" },
        :default_url => "/assets/blog/default_cover1.gif"

  def normalize_friendly_id(input)
    input.to_s.to_slug.normalize().to_s
  end

end
