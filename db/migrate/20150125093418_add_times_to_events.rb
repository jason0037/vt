class AddTimesToEvents < ActiveRecord::Migration
  def self.up
    change_table :events do |t|
     # t.column :times, :timestamp

      t.string :adds   ###地点

      t.column :terminal ,"ENUM('pc','mobile')",:default=>"pc"


    end
  end
end
