class AddRecoNameToPromotion < ActiveRecord::Migration


  def self.up
    change_table :sdb_imodec_promotions do |t|

      t.string :reco_name
      t.text :reco_val
      t.string :reco_in_or_not
    end
  end
  def self.down
    raise ActiveRecord::IrreversibleMigration
  end

  def connection
    @connection = Ecstore::Base.connection
  end

end
