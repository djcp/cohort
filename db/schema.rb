# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090625174247) do

  create_table "contact_addresses", :force => true do |t|
    t.integer  "contact_id",                                     :null => false
    t.string   "street1",      :limit => 100
    t.string   "street2",      :limit => 100
    t.string   "city",         :limit => 100
    t.string   "state",        :limit => 50
    t.string   "zip",          :limit => 30
    t.string   "country",      :limit => 100
    t.string   "address_type", :limit => 100
    t.boolean  "is_primary",                  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contact_addresses", ["address_type"], :name => "index_contact_addresses_on_address_type"
  add_index "contact_addresses", ["city"], :name => "index_contact_addresses_on_city"
  add_index "contact_addresses", ["country"], :name => "index_contact_addresses_on_country"
  add_index "contact_addresses", ["is_primary"], :name => "index_contact_addresses_on_is_primary"
  add_index "contact_addresses", ["state"], :name => "index_contact_addresses_on_state"
  add_index "contact_addresses", ["street1"], :name => "index_contact_addresses_on_street1"
  add_index "contact_addresses", ["street2"], :name => "index_contact_addresses_on_street2"
  add_index "contact_addresses", ["zip"], :name => "index_contact_addresses_on_zip"

  create_table "contact_emails", :force => true do |t|
    t.integer  "contact_id",                                   :null => false
    t.string   "email",      :limit => 200,                    :null => false
    t.string   "email_type", :limit => 100
    t.boolean  "is_primary",                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contact_emails", ["contact_id", "email"], :name => "index_contact_emails_on_contact_id_and_email", :unique => true
  add_index "contact_emails", ["email"], :name => "index_contact_emails_on_email"
  add_index "contact_emails", ["email_type"], :name => "index_contact_emails_on_email_type"
  add_index "contact_emails", ["is_primary"], :name => "index_contact_emails_on_is_primary"

  create_table "contacts", :force => true do |t|
    t.string   "first_name",   :limit => 100
    t.string   "middle_name",  :limit => 100
    t.string   "last_name",    :limit => 100
    t.string   "organization", :limit => 250
    t.string   "title",        :limit => 250
    t.string   "work_url",     :limit => 300
    t.string   "personal_url", :limit => 300
    t.string   "other_url",    :limit => 300
    t.string   "work_phone",   :limit => 30
    t.string   "home_phone",   :limit => 30
    t.string   "mobile_phone", :limit => 25
    t.string   "fax",          :limit => 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts", ["first_name"], :name => "index_contacts_on_first_name"
  add_index "contacts", ["home_phone"], :name => "index_contacts_on_home_phone"
  add_index "contacts", ["last_name"], :name => "index_contacts_on_last_name"
  add_index "contacts", ["mobile_phone"], :name => "index_contacts_on_mobile_phone"
  add_index "contacts", ["work_phone"], :name => "index_contacts_on_work_phone"

  create_table "freemailer_campaign_contacts", :force => true do |t|
    t.integer  "freemailer_campaign_id"
    t.integer  "contact_id"
    t.string   "delivery_status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "freemailer_campaigns", :force => true do |t|
    t.string   "subject"
    t.string   "title"
    t.text     "body_template"
    t.integer  "sender_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "sent",          :default => false
  end

  create_table "log_items", :force => true do |t|
    t.integer  "user_id",                    :null => false
    t.integer  "item_id",                    :null => false
    t.string   "item_type",  :limit => 500,  :null => false
    t.string   "message",    :limit => 1000, :null => false
    t.string   "kind",       :limit => 50,   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notes", :force => true do |t|
    t.integer  "user_id",                    :null => false
    t.integer  "contact_id",                 :null => false
    t.string   "note",       :limit => 5000, :null => false
    t.datetime "follow_up"
    t.integer  "priority"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["contact_id"], :name => "index_notes_on_contact_id"
  add_index "notes", ["created_at"], :name => "index_notes_on_created_at"
  add_index "notes", ["follow_up"], :name => "index_notes_on_follow_up"
  add_index "notes", ["position"], :name => "index_notes_on_position"
  add_index "notes", ["priority"], :name => "index_notes_on_priority"
  add_index "notes", ["updated_at"], :name => "index_notes_on_updated_at"
  add_index "notes", ["user_id"], :name => "index_notes_on_user_id"
  add_index "notes", ["note"], :name => "lower_note", :case_sensitive => false

  create_table "saved_search_runs", :force => true do |t|
    t.integer  "saved_search_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "saved_searches", :force => true do |t|
    t.integer  "user_id",                                          :null => false
    t.string   "name",          :limit => 200,                     :null => false
    t.string   "description",   :limit => 1000
    t.string   "search_url",    :limit => 5000,                    :null => false
    t.string   "category",      :limit => 100
    t.boolean  "global_search",                 :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "saved_searches", ["category"], :name => "index_saved_searches_on_category"
  add_index "saved_searches", ["name"], :name => "index_saved_searches_on_name"

  create_table "taggings", :force => true do |t|
    t.integer  "freetaggable_id"
    t.string   "freetaggable_type"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["created_at"], :name => "index_taggings_on_created_at"
  add_index "taggings", ["freetaggable_id"], :name => "index_taggings_on_freetaggable_id"
  add_index "taggings", ["freetaggable_id", "freetaggable_type", "tag_id"], :name => "index_taggings_on_freetaggable_id_and_freetaggable_type_and_tag", :unique => true
  add_index "taggings", ["freetaggable_type"], :name => "index_taggings_on_freetaggable_type"
  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["updated_at"], :name => "index_taggings_on_updated_at"

  create_table "tags", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "position"
    t.integer  "children_count"
    t.integer  "ancestors_count"
    t.integer  "descendants_count"
    t.boolean  "hidden"
    t.string   "title"
    t.string   "description"
    t.string   "tag_path"
    t.boolean  "removable",         :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["parent_id"], :name => "index_tags_on_parent_id"
  add_index "tags", ["position"], :name => "index_tags_on_position"
  add_index "tags", ["removable"], :name => "index_tags_on_removable"
  add_index "tags", ["title"], :name => "index_tags_on_title"

  create_table "users", :force => true do |t|
    t.string   "username",           :limit => 100,                    :null => false
    t.boolean  "superadmin",                        :default => false
    t.boolean  "immutable",                         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "active_campaign_id"
  end

  add_index "users", ["immutable"], :name => "index_users_on_immutable"
  add_index "users", ["superadmin"], :name => "index_users_on_superadmin"
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  add_foreign_key "contact_addresses", ["contact_id"], "contacts", ["id"], :on_update => :cascade, :on_delete => :cascade, :name => "contact_addresses_contact_id_fkey"

  add_foreign_key "contact_emails", ["contact_id"], "contacts", ["id"], :on_update => :cascade, :on_delete => :cascade, :name => "contact_emails_contact_id_fkey"

  add_foreign_key "freemailer_campaign_contacts", ["freemailer_campaign_id"], "freemailer_campaigns", ["id"], :name => "freemailer_campaign_contacts_freemailer_campaign_id_fkey"
  add_foreign_key "freemailer_campaign_contacts", ["contact_id"], "contacts", ["id"], :name => "freemailer_campaign_contacts_contact_id_fkey"

  add_foreign_key "freemailer_campaigns", ["sender_id"], "users", ["id"], :name => "freemailer_campaigns_sender_id_fkey"

  add_foreign_key "log_items", ["user_id"], "users", ["id"], :on_update => :cascade, :on_delete => :cascade, :name => "log_items_user_id_fkey"

  add_foreign_key "notes", ["user_id"], "users", ["id"], :on_update => :cascade, :on_delete => :cascade, :name => "notes_user_id_fkey"
  add_foreign_key "notes", ["contact_id"], "contacts", ["id"], :on_update => :cascade, :on_delete => :cascade, :name => "notes_contact_id_fkey"

  add_foreign_key "saved_search_runs", ["saved_search_id"], "saved_searches", ["id"], :on_update => :cascade, :on_delete => :cascade, :name => "saved_search_runs_saved_search_id_fkey"

  add_foreign_key "saved_searches", ["user_id"], "users", ["id"], :on_update => :cascade, :on_delete => :cascade, :name => "saved_searches_user_id_fkey"

  add_foreign_key "taggings", ["tag_id"], "tags", ["id"], :name => "taggings_tag_id_fkey"

  add_foreign_key "tags", ["parent_id"], "tags", ["id"], :name => "tags_parent_id_fkey"

  add_foreign_key "users", ["active_campaign_id"], "freemailer_campaigns", ["id"], :name => "users_active_campaign_id_fkey"

  create_view "pg_buffercache", "SELECT p.bufferid, p.relfilenode, p.reltablespace, p.reldatabase, p.relblocknumber, p.isdirty, p.usagecount FROM pg_buffercache_pages() p(bufferid integer, relfilenode oid, reltablespace oid, reldatabase oid, relblocknumber bigint, isdirty boolean, usagecount smallint);"
  create_view "pg_freespacemap_pages", "SELECT p.reltablespace, p.reldatabase, p.relfilenode, p.relblocknumber, p.bytes FROM pg_freespacemap_pages() p(reltablespace oid, reldatabase oid, relfilenode oid, relblocknumber bigint, bytes integer);"
  create_view "pg_freespacemap_relations", "SELECT p.reltablespace, p.reldatabase, p.relfilenode, p.avgrequest, p.interestingpages, p.storedpages, p.nextpage FROM pg_freespacemap_relations() p(reltablespace oid, reldatabase oid, relfilenode oid, avgrequest integer, interestingpages integer, storedpages integer, nextpage integer);"

end
