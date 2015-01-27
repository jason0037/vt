class AddTimesToEvents < ActiveRecord::Migration
  def self.up
    change_table :events do |t|
      t.integer :startime

      t.string :adds   ###地点

      t.column :terminal ,"ENUM('pc','mobile')",:default=>"pc"
      t.integer :member_id
      t.integer :endtime

    end
  end
end
