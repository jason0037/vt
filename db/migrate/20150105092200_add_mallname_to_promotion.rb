class AddMallnameToPromotion < ActiveRecord::Migration
  def self.up
    change_table :sdb_imodec_promotions do |t|
      t.string :mallname     ###馆名指定
      t.integer :supplier_id  ##当前商品供应商


    end
  end

  def connection
    @connection = Ecstore::Base.connection
  end

end
