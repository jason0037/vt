class AddFieldsToHomes < ActiveRecord::Migration
  def change
  	add_column :sdb_imodec_homes,:sliders,:string
  	add_column :sdb_imodec_homes,:keywords,:string
  	add_column :sdb_imodec_homes,:pops,:string
  	add_column :sdb_imodec_homes,:clothing,:string
  	add_column :sdb_imodec_homes,:bags,:string
  end

  def connection
  	@connection =  Ecstore::Base.connection
  end
end
