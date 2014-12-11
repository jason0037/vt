class CreateVisitors < ActiveRecord::Migration
  def change

    create_table :visitors do |t|
     t.string :visitor_name
     t.string :visitor_password
     t.string :address
     t.string :tel
     t.string :phone
     t.string :postal

      t.timestamps
    end
  end
  def connection
    @connection = Ecstore::Base.connection
  end

end
