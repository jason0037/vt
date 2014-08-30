class AddBankToMembers < ActiveRecord::Migration
  def change
    add_column :sdb_b2c_members, :bank_info, "varchar(255)"

  #  '{"bank"=>"工商银行","account"=>"62349349834883294","bank_branch"=>"上海市市北支行"}'
  # '{"bank"=>"支付宝","account"=>"abce@email.com","bank_brank"=>""}'
  end

  def connection
    @connection = Ecstore::Base.connection
  end
end