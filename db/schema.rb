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

ActiveRecord::Schema.define(version: 20150906094228) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "area_level1s", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "area_level2s", force: :cascade do |t|
    t.string   "long_name"
    t.string   "short_name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "area_level1_id"
  end

  add_index "area_level2s", ["area_level1_id"], name: "index_area_level2s_on_area_level1_id", using: :btree

  create_table "area_level3s", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "area_level2_id"
  end

  add_index "area_level3s", ["area_level2_id"], name: "index_area_level3s_on_area_level2_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.string   "descr"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categorizations", force: :cascade do |t|
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "partnership_id"
    t.integer  "category_id"
  end

  add_index "categorizations", ["category_id"], name: "index_categorizations_on_category_id", using: :btree
  add_index "categorizations", ["partnership_id"], name: "index_categorizations_on_partnership_id", using: :btree

  create_table "offices", force: :cascade do |t|
    t.string   "address"
    t.string   "additional"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "tel"
    t.string   "fax"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "area_level1_id"
    t.integer  "area_level3_id"
    t.integer  "partner_id"
  end

  add_index "offices", ["area_level1_id"], name: "index_offices_on_area_level1_id", using: :btree
  add_index "offices", ["area_level3_id"], name: "index_offices_on_area_level3_id", using: :btree
  add_index "offices", ["partner_id"], name: "index_offices_on_partner_id", using: :btree

  create_table "partners", force: :cascade do |t|
    t.string   "name"
    t.string   "note"
    t.string   "vat"
    t.string   "activities"
    t.string   "website"
    t.string   "logo"
    t.string   "active"
    t.string   "p_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "partnerships", force: :cascade do |t|
    t.datetime "signing_date"
    t.boolean  "active"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "partner_id"
    t.integer  "office_id"
  end

  add_index "partnerships", ["office_id"], name: "index_partnerships_on_office_id", using: :btree
  add_index "partnerships", ["partner_id"], name: "index_partnerships_on_partner_id", using: :btree

  create_table "representatives", force: :cascade do |t|
    t.string   "title"
    t.string   "name"
    t.string   "tel"
    t.string   "fax"
    t.string   "email"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "partnership_id"
  end

  add_index "representatives", ["partnership_id"], name: "index_representatives_on_partnership_id", using: :btree

  create_table "titles", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "area_level2s", "area_level1s"
  add_foreign_key "area_level3s", "area_level2s"
  add_foreign_key "categorizations", "categories"
  add_foreign_key "categorizations", "partnerships"
  add_foreign_key "offices", "area_level1s"
  add_foreign_key "offices", "area_level3s"
  add_foreign_key "offices", "partners"
  add_foreign_key "partnerships", "offices"
  add_foreign_key "partnerships", "partners"
  add_foreign_key "representatives", "partnerships"
end
