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

ActiveRecord::Schema.define(version: 20160228150205) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "notifications", id: false, force: :cascade do |t|
    t.integer  "user_id",             null: false
    t.integer  "subject_id",          null: false
    t.string   "subject_type",        null: false
    t.datetime "created_at",          null: false
    t.string   "kind",                null: false
    t.integer  "originating_user_id"
    t.index ["originating_user_id"], name: "index_notifications_on_originating_user_id", using: :btree
    t.index ["subject_id", "subject_type"], name: "index_notifications_on_subject_id_and_subject_type", using: :btree
    t.index ["user_id", "created_at", "subject_id", "subject_type", "kind", "originating_user_id"], name: "covering_index_on_notifications", unique: true, using: :btree
  end

end
