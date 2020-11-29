# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_29_082405) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.integer "postal_code", null: false
    t.string "prefecture", null: false
    t.string "city", null: false
    t.text "address1", null: false
    t.text "address2"
    t.string "family_name", null: false
    t.string "given_name", null: false
    t.string "email", null: false
  end

  create_table "order_details", force: :cascade do |t|
    t.integer "product_id"
    t.integer "product_count"
    t.integer "cart_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "price", null: false
    t.text "image", default: "https://lh3.googleusercontent.com/proxy/dnjS9wh1fZY69IOgfhi1kkE2gbA9sM9KW-5fpHJ7Lsfhy84sKN0fpmFHk4hqNPFUXCJiv6_g_tFjGKSTE7JfHdaAYa5qZpg1awLEGYQ"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
