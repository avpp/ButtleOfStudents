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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141119111533) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answers", force: true do |t|
    t.text     "options"
    t.integer  "user_id"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "battles", force: true do |t|
    t.text     "options"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "battles", ["user_id"], name: "index_battles_on_user_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name",              limit: 40
    t.string   "authorizable_type", limit: 40
    t.integer  "authorizable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["authorizable_type", "authorizable_id"], name: "index_roles_on_authorizable_type_and_authorizable_id", using: :btree

  create_table "roles_users", id: false, force: true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles_users", ["role_id"], name: "index_roles_users_on_role_id", using: :btree
  add_index "roles_users", ["user_id"], name: "index_roles_users_on_user_id", using: :btree

  create_table "student_battles", force: true do |t|
    t.integer  "user_id"
    t.integer  "battle_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.datetime "team_assign_time"
  end

  create_table "task_types", force: true do |t|
    t.text     "options"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", force: true do |t|
    t.integer  "task_type_id"
    t.integer  "team_id"
    t.integer  "user_id"
    t.text     "options"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "battle_id"
  end

  add_index "tasks", ["battle_id"], name: "index_tasks_on_battle_id", using: :btree

  create_table "teams", force: true do |t|
    t.string   "name"
    t.integer  "battle_id"
    t.text     "options"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",               default: "", null: false
    t.string   "encrypted_password",  default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "info"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
