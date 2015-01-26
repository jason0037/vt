class AddWechatNumToApplicants < ActiveRecord::Migration
  def self.up
    change_table :applicants do |t|
      t.string :member_id

    end
  end
end
