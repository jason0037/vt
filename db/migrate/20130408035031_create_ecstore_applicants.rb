class CreateEcstoreApplicants < ActiveRecord::Migration
  def change
    create_table :applicants do |t|
      t.string :name
      t.string :sex
      t.integer :age
      t.string :mobile
      t.string :email
      t.integer :event_id

      t.timestamps
    end
  end
  
end
