class Imodec::Category < ActiveRecord::Base
  attr_accessible :name

  has_many :topics
end
