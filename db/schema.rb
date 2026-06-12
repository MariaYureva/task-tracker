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

ActiveRecord::Schema[7.1].define(version: 2026_01_01_000007) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "recurrence_dates", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id", "date"], name: "index_recurrence_dates_on_task_id_and_date", unique: true
    t.index ["task_id"], name: "index_recurrence_dates_on_task_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "system", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_tags_on_lower_name", unique: true
  end

  create_table "task_exceptions", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.date "original_date", null: false
    t.date "scheduled_date"
    t.string "status"
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id", "original_date"], name: "index_task_exceptions_on_task_id_and_original_date", unique: true
    t.index ["task_id"], name: "index_task_exceptions_on_task_id"
  end

  create_table "task_tags", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_task_tags_on_tag_id"
    t.index ["task_id", "tag_id"], name: "index_task_tags_on_task_id_and_tag_id", unique: true
    t.index ["task_id"], name: "index_task_tags_on_task_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "state", default: "active", null: false
    t.date "starts_on", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "recurrence_type", default: "once", null: false
    t.integer "recurrence_interval", default: 1, null: false
    t.integer "monthly_day"
    t.date "ends_on"
    t.index ["recurrence_type"], name: "index_tasks_on_recurrence_type"
    t.index ["starts_on"], name: "index_tasks_on_starts_on"
    t.index ["user_id", "state"], name: "index_tasks_on_user_id_and_state"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "role", default: "doctor", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "recurrence_dates", "tasks"
  add_foreign_key "task_exceptions", "tasks"
  add_foreign_key "task_tags", "tags"
  add_foreign_key "task_tags", "tasks"
  add_foreign_key "tasks", "users"
end
