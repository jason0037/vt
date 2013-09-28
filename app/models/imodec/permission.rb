class Imodec::Permission < ActiveRecord::Base
  attr_accessible :manager_id, :rights
  
end
