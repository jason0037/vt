class AddWechatNumToMember < ActiveRecord::Migration
  def self.up
    change_table :sdb_b2c_members do |t|
       t.string :wechat_num   ###微信号
      t.text :user_desc
    end
  end
  def connection
    @connection = Ecstore::Base.connection
  end
end
