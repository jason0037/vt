#encoding : utf-8
class Imodec::Topic < ActiveRecord::Base
  COVER_SIZES = ['big', 'normal', 'small']

  has_many :pages
  has_many :comments, :foreign_key=>"commentable_id",:class_name=>"Ecstore::Comment"

  belongs_to :category

 

  extend FriendlyId
  friendly_id :slug
  # require "babosa"

  # validates_presence_of :title, :slug, :body
  attr_accessor :remove_cover
  attr_accessible :body, :published, :title, :summary, :cover, :remove_cover, :cover_size,:require_login,:pages,:category_id,:slug,:page_keywords,:page_description,:commentable
  has_attached_file :cover,
        :styles => { :small => "230x112#", :normal => "230x230#", :big => "465x230#" },
        :default_url => "/assets/blog/default_cover1.gif"

  before_save :perform_cover_removal

  def normalize_friendly_id(input)
    input.to_s.to_slug.normalize().to_s
  end

  def perform_cover_removal
    self.cover = nil if self.remove_cover=="1"
    true
  end

  def self.published
    self.where(:published=>true).where("published_at <= :now", {:now=>Time.now} )
  end

  def pages=(inner_pages)
      inner_pages.each do |page|
          if page.is_a?(Hash)
             epage =  Imodec::Page.find(page[:id])
            
             self.pages.delete_if { |p| p.id == epage.id }
             epage.body = page[:body]
             self.pages << epage
          else
             self.pages  << Imodec::Page.new(:body=>page) if page.strip.size > 0
          end
          
      end
  end

end