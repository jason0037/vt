class AddWechatNumToApplicants < ActiveRecord::Migration
  def self.up
    change_table :applicants do |t|
      t.string :wechat_num   ###微信号
    end
  end
end
