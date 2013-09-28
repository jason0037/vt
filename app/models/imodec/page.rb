class Imodec::Page < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :body, :title, :user_id, :topic_id

  belongs_to :topic
end
