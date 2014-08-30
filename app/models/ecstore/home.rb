#encoding:utf-8
class Ecstore::Home < Ecstore::Base
  self.table_name  = 'sdb_imodec_homes'
  attr_accessible :body,:note,:sliders,:keywords,:pops,:clothing,:bags,:suits,:hots,:supplier_id

  belongs_to :supplier,	:foreign_key=>"supplier_id"

  include Ecstore::Metable

  validates_presence_of :body, :message=>"内容不能为空"
  [:sliders,:keywords,:pops,:clothing,:bags,:suits,:hots].each do |json_field|
  	class_eval <<-JSON,__FILE__,__LINE__+1
  		def #{json_field}=(val)
  		      super ActiveSupport::JSON.encode(val)
  		end

  		def #{json_field}
                   return []  if super.blank?
  		      return ActiveSupport::JSON.decode(super) if super.present?
                   return super
  		end
  	JSON
  end


  [:pops,:clothing,:bags].each do |arr|
  	class_eval <<-ARR,__FILE__,__LINE__+1
  		def goods_of_#{arr}
  			self.#{arr}.collect { |bn| Ecstore::Good.find_by_bn(bn) }.compact
  		end
  	ARR
  end

  def goods_of_hots
     Ecstore::Good.where(:bn=>self.hots).order("RAND()").limit(4)
  end

end
