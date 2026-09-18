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

ActiveRecord::Schema[8.1].define(version: 2026_09_18_072137) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"

  create_table "appointments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "cancellation_reason"
    t.datetime "created_at", null: false
    t.integer "duration", default: 30, null: false
    t.uuid "patient_profile_id", null: false
    t.uuid "practitioner_profile_id", null: false
    t.text "reason"
    t.datetime "scheduled_at", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["patient_profile_id", "scheduled_at"], name: "index_appointments_on_patient_profile_id_and_scheduled_at"
    t.index ["patient_profile_id"], name: "index_appointments_on_patient_profile_id"
    t.index ["practitioner_profile_id", "scheduled_at"], name: "index_appointments_on_practitioner_profile_id_and_scheduled_at"
    t.index ["practitioner_profile_id"], name: "index_appointments_on_practitioner_profile_id"
    t.index ["status"], name: "index_appointments_on_status"
  end

  create_table "availabilities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "day_of_week", null: false
    t.time "end_time", null: false
    t.uuid "practitioner_profile_id", null: false
    t.time "start_time", null: false
    t.datetime "updated_at", null: false
    t.index ["practitioner_profile_id", "day_of_week"], name: "idx_on_practitioner_profile_id_day_of_week_e0a6c5aa41"
    t.index ["practitioner_profile_id"], name: "index_availabilities_on_practitioner_profile_id"
  end

  create_table "availability_exceptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.time "end_time"
    t.integer "exception_type", default: 0, null: false
    t.uuid "practitioner_profile_id", null: false
    t.string "reason"
    t.time "start_time"
    t.datetime "updated_at", null: false
    t.index ["practitioner_profile_id", "date"], name: "idx_on_practitioner_profile_id_date_1717301765"
    t.index ["practitioner_profile_id"], name: "index_availability_exceptions_on_practitioner_profile_id"
  end

  create_table "availability_rules", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.integer "day_of_week", null: false
    t.time "end_time", null: false
    t.uuid "practitioner_profile_id", null: false
    t.integer "slot_duration_minutes", default: 30, null: false
    t.time "start_time", null: false
    t.datetime "updated_at", null: false
    t.date "valid_from", null: false
    t.date "valid_until"
    t.index ["practitioner_profile_id", "day_of_week"], name: "idx_on_practitioner_profile_id_day_of_week_089954537c"
    t.index ["practitioner_profile_id"], name: "index_availability_rules_on_practitioner_profile_id"
    t.check_constraint "start_time < end_time", name: "start_before_end_check"
  end

  create_table "cabinets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "address"
    t.string "city"
    t.datetime "created_at", null: false
    t.float "latitude"
    t.float "longitude"
    t.string "name", null: false
    t.string "phone_number"
    t.string "postal_code"
    t.datetime "updated_at", null: false
    t.index ["city"], name: "index_cabinets_on_city"
    t.index ["latitude", "longitude"], name: "index_cabinets_on_latitude_and_longitude"
  end

  create_table "patient_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "address"
    t.string "city"
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "first_name"
    t.string "last_name"
    t.float "latitude"
    t.float "longitude"
    t.string "phone_number"
    t.string "postal_code"
    t.string "social_security_number_bidx"
    t.string "social_security_number_ciphertext"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["latitude", "longitude"], name: "index_patient_profiles_on_latitude_and_longitude"
    t.index ["social_security_number_bidx"], name: "index_patient_profiles_on_social_security_number_bidx", unique: true
    t.index ["user_id"], name: "index_patient_profiles_on_user_id", unique: true
  end

  create_table "practitioner_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "bio"
    t.uuid "cabinet_id"
    t.integer "consultation_price_cents"
    t.datetime "created_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "rpps_number"
    t.integer "sector", default: 0
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.boolean "verified", default: false
    t.index ["cabinet_id"], name: "index_practitioner_profiles_on_cabinet_id"
    t.index ["rpps_number"], name: "index_practitioner_profiles_on_rpps_number", unique: true
    t.index ["user_id"], name: "index_practitioner_profiles_on_user_id", unique: true
  end

  create_table "practitioner_profiles_specialities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "practitioner_profile_id", null: false
    t.uuid "speciality_id", null: false
    t.index ["practitioner_profile_id", "speciality_id"], name: "index_practitionner_specialities_unique", unique: true
    t.index ["practitioner_profile_id"], name: "idx_on_practitioner_profile_id_739dc2fdd4"
    t.index ["speciality_id"], name: "index_practitioner_profiles_specialities_on_speciality_id"
  end

  create_table "specialities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_specialities_on_slug", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "jti", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "appointments", "patient_profiles"
  add_foreign_key "appointments", "practitioner_profiles"
  add_foreign_key "availabilities", "practitioner_profiles"
  add_foreign_key "availability_exceptions", "practitioner_profiles"
  add_foreign_key "availability_rules", "practitioner_profiles"
  add_foreign_key "patient_profiles", "users"
  add_foreign_key "practitioner_profiles", "cabinets"
  add_foreign_key "practitioner_profiles", "users"
  add_foreign_key "practitioner_profiles_specialities", "specialities"
end
