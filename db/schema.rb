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

ActiveRecord::Schema.define(version: 2019_03_21_212313) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "campaigns", force: :cascade do |t|
    t.bigint "vertical_id"
    t.integer "contacts_count", default: 0
    t.integer "sold_count", default: 0
    t.integer "refund_count", default: 0
    t.integer "talk_average", default: 0
    t.string "name"
    t.integer "campaign_type"
    t.string "client_did"
    t.datetime "schedule_start"
    t.datetime "schedule_end"
    t.string "blocked_states"
    t.string "order_total"
    t.string "daily_call_limit"
    t.string "concurrent_call_limit"
    t.string "buyer_balance"
    t.string "buffer"
    t.string "lead_cost"
    t.string "vicidial_agent_user"
    t.boolean "vicidial_remote_agent", default: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vertical_id"], name: "index_campaigns_on_vertical_id"
    t.index ["vicidial_agent_user"], name: "index_campaigns_on_vicidial_agent_user"
  end

  create_table "campaigns_funnels", id: false, force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.bigint "funnel_id", null: false
    t.index ["campaign_id", "funnel_id"], name: "index_campaigns_funnels_on_campaign_id_and_funnel_id"
  end

  create_table "charges", force: :cascade do |t|
    t.bigint "user_id"
    t.decimal "amount", precision: 11, scale: 4
    t.string "stripe_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "contact_id"
    t.index ["contact_id"], name: "index_charges_on_contact_id"
    t.index ["user_id"], name: "index_charges_on_user_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "campaign_id"
    t.string "lead_id"
    t.string "vendor_id"
    t.string "phone_number"
    t.string "group"
    t.string "user"
    t.string "term_reason"
    t.integer "length_in_sec", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_contacts_on_campaign_id"
    t.index ["lead_id"], name: "index_contacts_on_lead_id"
  end

  create_table "dids", force: :cascade do |t|
    t.bigint "funnel_id"
    t.string "number"
    t.integer "calls_count", default: 0
    t.integer "sold_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["funnel_id"], name: "index_dids_on_funnel_id"
    t.index ["number"], name: "index_dids_on_number"
  end

  create_table "funnel_ivrs", force: :cascade do |t|
    t.integer "funnel_id"
    t.integer "ivr_id"
    t.integer "rank"
    t.string "options"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["funnel_id", "ivr_id"], name: "index_funnel_ivrs_on_funnel_id_and_ivr_id"
  end

  create_table "funnels", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "vertical_id"
    t.string "name"
    t.string "forwarding_number"
    t.integer "routing_type"
    t.boolean "mask_number", default: false
    t.boolean "active", default: true
    t.string "vicidial_ingroup_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_funnels_on_user_id"
    t.index ["vertical_id"], name: "index_funnels_on_vertical_id"
  end

  create_table "globals", force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ivrs", force: :cascade do |t|
    t.string "name"
    t.string "recording_file"
    t.string "options"
    t.string "vici_callmenu"
    t.integer "funnel_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_ivrs_on_user_id"
  end

  create_table "sources", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.integer "calls_count", default: 0
    t.integer "sold_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sources_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.boolean "buyer", default: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "email_confirmed", default: false
    t.string "confirm_token"
    t.datetime "password_reset_sent_at"
    t.string "password_reset_token"
    t.decimal "balance", precision: 11, scale: 4, default: "0.0"
    t.decimal "billing_rate", precision: 11, scale: 4
    t.integer "master_user_id"
    t.integer "buyer_campaign_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "send_billing_reminder", default: true
    t.index ["buyer_campaign_id"], name: "index_users_on_buyer_campaign_id"
    t.index ["master_user_id"], name: "index_users_on_master_user_id"
  end

  create_table "verticals", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.integer "calls_count", default: 0
    t.integer "sold_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_verticals_on_user_id"
  end

end
