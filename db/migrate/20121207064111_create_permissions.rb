class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.integer :manager_id
      t.text :rights

      t.timestamps
    end
  end
end
