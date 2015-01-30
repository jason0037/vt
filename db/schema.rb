# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 201412081010300) do

  create_table "accounts_resources", :id => false, :force => true do |t|
    t.integer "account_id"
    t.integer "resource_id"
  end

  create_table "applicants", :force => true do |t|
    t.string   "name"
    t.string   "sex"
    t.integer  "age"
    t.string   "mobile"
    t.string   "email"
    t.integer  "event_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "wechat_num"
    t.string   "member_id"
    t.text     "user_desc"
  end

  create_table "articles", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "user_id"
    t.datetime "published_at"
    t.boolean  "published",          :default => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "slug",                                  :null => false
    t.boolean  "headlined",          :default => false
    t.text     "summary"
    t.string   "cover_file_name"
    t.string   "cover_content_type"
    t.integer  "cover_file_size"
    t.datetime "cover_updated_at"
    t.integer  "position_id"
  end

  add_index "articles", ["slug"], :name => "index_articles_on_slug", :unique => true

  create_table "categories", :force => true do |t|
    t.string "name"
  end

  create_table "ckeditor_assets", :force => true do |t|
    t.string   "data_file_name",                  :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "idx_ckeditor_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_ckeditor_assetable_type"

  create_table "ecstore_orders", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "events", :force => true do |t|
    t.string   "name"
    t.text     "body"
    t.string   "slug"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "startime"
    t.string   "adds"
    t.string   "terminal",   :limit => 6, :default => "pc"
    t.integer  "member_id"
    t.integer  "endtime"
  end

  add_index "events", ["slug"], :name => "index_events_on_slug", :unique => true

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "topic_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
  end

  create_table "permissions", :force => true do |t|
    t.integer  "manager_id"
    t.text     "rights"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "permissions0", :force => true do |t|
    t.integer  "manager_id"
    t.text     "rights"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "resources", :force => true do |t|
    t.integer "parent_id"
    t.string  "name"
    t.string  "description"
  end

  create_table "sdb_pam_auth_ext", :force => true do |t|
    t.integer  "account_id"
    t.string   "access_token"
    t.integer  "expires_in"
    t.integer  "expires_at"
    t.string   "uid"
    t.string   "provider"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "topics", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "user_id"
    t.datetime "published_at"
    t.boolean  "published",          :default => false
    t.string   "slug"
    t.text     "summary"
    t.string   "cover_file_name"
    t.string   "cover_content_type"
    t.integer  "cover_file_size"
    t.datetime "cover_updated_at"
    t.integer  "position_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "cover_size",         :default => "big"
    t.boolean  "require_login",      :default => true
    t.integer  "category_id"
    t.string   "page_keywords"
    t.string   "page_description"
    t.boolean  "commentable",        :default => false
  end

  add_index "topics", ["slug"], :name => "index_topics_on_slug", :unique => true

end
