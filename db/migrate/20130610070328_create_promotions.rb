class CreatePromotions < ActiveRecord::Migration
  def up
    create_table :sdb_imodec_promotions,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
      t.string :name
      t.string :desc
      t.integer :priority
      t.datetime :begin_at
      t.datetime :end_at
      t.boolean :exclusive
      t.text :goods
      t.string :condition_type
      t.string :condition_val
      t.string :action_type
      t.text :action_val
      t.boolean :enable
      t.string :promotion_type

      t.timestamps
    end
  end

  def down
    drop_table :sdb_imodec_promotions
  end

  def connection
    @connection = Ecstore::Base.connection
  end
end
