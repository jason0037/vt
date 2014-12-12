<<<<<<< HEAD
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
=======
class CreateVisitors < ActiveRecord::Migration
  def change

    create_table :visitors do |t|
     t.string :visitor_name
     t.string :visitor_password
    


      t.timestamps
    end
  end
  def connection
    @connection = Ecstore::Base.connection
  end

end
>>>>>>> 896dafebe2ab348b1366f1ef9b4dd0434eaf2667
