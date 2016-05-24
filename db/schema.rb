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

ActiveRecord::Schema.define(version: 20160524215250) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "homes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orderitems", force: :cascade do |t|
    t.integer  "quantity"
    t.float    "price"
    t.integer  "order_id"
    t.integer  "product_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "user_id"
    t.boolean  "shipped",    default: false
  end

  create_table "orders", force: :cascade do |t|
    t.string   "status"
    t.float    "price"
    t.integer  "user_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "email"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "name_on_credit_card"
    t.integer  "credit_card_number"
    t.integer  "credit_card_cvv"
    t.string   "billing_zip"
    t.date     "credit_card_exp_date"
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.float    "price"
    t.integer  "quantity"
    t.float    "rating"
    t.string   "description"
    t.string   "category"
    t.string   "photo_url"
    t.string   "status"
    t.integer  "user_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "animal"
    t.string   "new_category"
    t.boolean  "retired",      default: false
    t.integer  "weight"
    t.integer  "height"
    t.integer  "width"
  end

  create_table "reviews", force: :cascade do |t|
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "description"
    t.string   "rating"
    t.string   "product_id"
    t.string   "user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password"
    t.string   "full_name"
    t.string   "cc_number"
    t.string   "exp_date"
    t.integer  "cvv"
    t.string   "zip"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "password_digest"
  end

end
