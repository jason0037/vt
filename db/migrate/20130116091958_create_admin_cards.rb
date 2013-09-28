class CreateAdminCards < ActiveRecord::Migration
  def change
    create_table :sdb_imodec_cards,:options => 'ENGINE=MyISAM DEFAULT CHARSET=utf8' do |t|
      t.string :no
      t.integer :value
      t.string :card_type
      t.string :sale_status
      t.string :use_status
      t.string :status
      t.string :buyer_tel
      t.string :user_tel

      t.timestamps
    end
  end

  def connection
    @connection = Ecstore::Base.connection
  end
  
end
