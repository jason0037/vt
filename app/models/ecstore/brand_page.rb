class Ecstore::BrandPage < Ecstore::Base
  self.table_name = 'sdb_b2c_brand_pages'
  belongs_to :brand
  attr_accessible :brand_id, :context, :logo_url,:brand_reco,:new_body

  def context=(val)
  	super(val.to_json)
  end

  def context
  	return ActiveSupport::JSON.decode super if super.present?
  	return []
  end

end
