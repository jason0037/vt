class CreateResources < ActiveRecord::Migration
  def up
  	create_table :resources do |t|
            t.integer :parent_id
  		t.string :name
  		t.string :description
  	end
  end

  def down
  	drop_table :resources
  end
end
