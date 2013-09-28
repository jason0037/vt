class CreateAccountsResources < ActiveRecord::Migration
  def up
  	create_table :accounts_resources,:id=>false do |t|
  		t.integer :account_id
  		t.integer :resource_id
  	end
  end

  def down
  	drop_table :accounts_resources
  end
end
