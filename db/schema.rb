# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_13_213651) do
  create_table "guests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "flagged_shared"
    t.datetime "invitation_sent_at"
    t.string "name"
    t.string "phone"
    t.string "token"
    t.datetime "updated_at", null: false
    t.string "verified_ip"
    t.integer "verify_attempts"
    t.datetime "verify_locked_until"
    t.integer "wedding_id", null: false
    t.index ["token"], name: "index_guests_on_token", unique: true
    t.index ["wedding_id"], name: "index_guests_on_wedding_id"
  end

  create_table "rsvps", force: :cascade do |t|
    t.boolean "bringing_spouse", default: false
    t.boolean "checked_in", default: false, null: false
    t.datetime "created_at", null: false
    t.integer "guest_id", null: false
    t.text "message"
    t.integer "seats_reserved", default: 1
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["guest_id"], name: "index_rsvps_on_guest_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "weddings", force: :cascade do |t|
    t.string "bride_name"
    t.string "church_venue"
    t.string "couple_photo"
    t.datetime "created_at", null: false
    t.string "groom_name"
    t.string "theme"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "venue"
    t.date "wedding_date"
    t.text "welcome_message"
    t.index ["user_id"], name: "index_weddings_on_user_id"
  end

  add_foreign_key "guests", "weddings"
  add_foreign_key "rsvps", "guests"
  add_foreign_key "weddings", "users"
end
