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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_19_064714) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "blacklist_members", force: :cascade do |t|
    t.string "profile_url"
    t.text "description"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.index ["user_id"], name: "index_blacklist_members_on_user_id"
  end

  create_table "campaign_logs", force: :cascade do |t|
    t.text "log"
    t.bigint "campaign_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.index ["campaign_id"], name: "index_campaign_logs_on_campaign_id"
  end

  create_table "campaign_members", force: :cascade do |t|
    t.string "public_identifier"
    t.string "first_name"
    t.string "last_name"
    t.string "location"
    t.string "company"
    t.string "image_url"
    t.string "summary"
    t.string "profile_url"
    t.string "title"
    t.string "full_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "campaign_id"
    t.boolean "status", default: false
    t.boolean "is_premium"
    t.datetime "accepted_at"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
  end

  create_table "campaign_members_messages", force: :cascade do |t|
    t.bigint "campaign_member_id"
    t.bigint "campaign_message_id"
    t.datetime "sending_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.index ["campaign_member_id"], name: "index_campaign_members_messages_on_campaign_member_id"
    t.index ["campaign_message_id"], name: "index_campaign_members_messages_on_campaign_message_id"
  end

  create_table "campaign_messages", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.bigint "campaign_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "number_of_days"
    t.boolean "status", default: false
    t.integer "template_id"
    t.datetime "sending_date"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.index ["campaign_id"], name: "index_campaign_messages_on_campaign_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.boolean "withdramConnectionAtDay"
    t.decimal "maxConnectionPageSentPerDay"
    t.string "url"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "template_id"
    t.text "description"
    t.datetime "run_at"
    t.datetime "end_at"
    t.text "custom_message"
    t.string "campaign_type"
    t.boolean "is_include_premium_profile", default: true
    t.boolean "is_include_without_avatar_profile", default: true
    t.boolean "is_skip_premium_profile", default: false
    t.boolean "is_skip_without_avatar_profile", default: false
    t.boolean "is_only_premium", default: false
    t.integer "max_limit"
    t.integer "limit", default: 0
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "campaign_id"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "invitations", force: :cascade do |t|
    t.bigint "user_id"
    t.boolean "is_accept"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "public_identifier"
    t.string "status"
    t.integer "receiver_id"
    t.integer "campaign_id"
    t.string "email"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.index ["user_id"], name: "index_invitations_on_user_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
  end

  create_table "listing_members", force: :cascade do |t|
    t.string "profile_url"
    t.string "full_name"
    t.string "summary"
    t.string "title"
    t.string "image_url"
    t.string "location"
    t.string "public_identifier"
    t.boolean "is_premium"
    t.bigint "listing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "emails", default: [], array: true
    t.datetime "emails_updated_at"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.index ["listing_id"], name: "index_listing_members_on_listing_id"
  end

  create_table "listings", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.index ["user_id"], name: "index_listings_on_user_id"
  end

  create_table "members_listings", force: :cascade do |t|
    t.bigint "listing_member_id"
    t.bigint "listing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.index ["listing_id"], name: "index_members_listings_on_listing_id"
    t.index ["listing_member_id"], name: "index_members_listings_on_listing_member_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "sender_id"
    t.string "receiver_id"
    t.text "message_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
  end

  create_table "pages", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
  end

  create_table "payment_notifications", force: :cascade do |t|
    t.bigint "user_id"
    t.boolean "status"
    t.integer "transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "payer_id"
    t.string "payment_id"
    t.boolean "is_cancel"
    t.boolean "is_paid"
    t.string "payment_token"
    t.string "recipient_name"
    t.string "address"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.index ["user_id"], name: "index_payment_notifications_on_user_id"
  end

  create_table "plans", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "invitations_per_day_limit"
    t.integer "emails_per_day_limit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "profiles_visit_limit"
    t.integer "send_message_limit"
    t.integer "connections_limit"
    t.integer "total_profiles_visit_limit"
    t.integer "total_send_messages_limit"
    t.integer "total_connections_limit"
    t.integer "total_follow_up_messages_limit"
    t.integer "profiles_visit_per_day_limit"
    t.integer "send_messages_per_day_limit"
    t.integer "follow_up_messages_per_day_limit"
    t.integer "total_invitations_limit"
    t.integer "total_emails_limit"
    t.integer "price"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
  end

  create_table "profiles", force: :cascade do |t|
    t.string "full_name"
    t.string "title"
    t.string "location"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "campaign_id"
    t.string "company_name"
    t.string "email"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
  end

  create_table "tags", force: :cascade do |t|
    t.bigint "campaign_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.index ["campaign_id"], name: "index_tags_on_campaign_id"
  end

  create_table "templates", force: :cascade do |t|
    t.string "template_name"
    t.text "template_subject"
    t.text "follow_up_message"
    t.integer "follow_up_days"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "body"
    t.string "template_type"
    t.text "user_details"
    t.integer "user_id"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "firstname"
    t.string "lastname"
    t.string "company"
    t.string "hunter_api_key"
    t.string "aeroleads_api_key"
    t.string "prospect_api_key"
    t.string "anymail_api_key"
    t.integer "plan_id"
    t.string "provider"
    t.string "uid"
    t.string "linkedin_cookie"
    t.string "token"
    t.datetime "activated_at"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string "linkedin_session_id"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "blacklist_members", "users"
  add_foreign_key "campaign_logs", "campaigns"
  add_foreign_key "campaign_members_messages", "campaign_members"
  add_foreign_key "campaign_members_messages", "campaign_messages"
  add_foreign_key "listing_members", "listings"
  add_foreign_key "listings", "users"
  add_foreign_key "members_listings", "listing_members"
  add_foreign_key "members_listings", "listings"
  add_foreign_key "payment_notifications", "users"
  add_foreign_key "tags", "campaigns"
end
