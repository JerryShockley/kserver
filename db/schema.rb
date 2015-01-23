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

ActiveRecord::Schema.define(version: 20150122230151) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "custom_look_products", force: true do |t|
    t.integer  "custom_look_id"
    t.integer  "product_app_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "custom_look_products", ["custom_look_id"], name: "index_custom_look_products_on_custom_look_id", using: :btree
  add_index "custom_look_products", ["product_app_id"], name: "index_custom_look_products_on_product_app_id", using: :btree

  create_table "custom_looks", force: true do |t|
    t.integer  "product_set_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "custom_looks", ["product_set_id"], name: "index_custom_looks_on_product_set_id", using: :btree
  add_index "custom_looks", ["user_id"], name: "index_custom_looks_on_user_id", using: :btree

  create_table "image_usages", force: true do |t|
    t.text     "page"
    t.text     "role"
    t.integer  "image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "image_usages", ["image_id"], name: "index_image_usages_on_image_id", using: :btree

  create_table "images", force: true do |t|
    t.text     "filename"
    t.integer  "user_id"
    t.boolean  "active"
    t.integer  "file_size"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["user_id"], name: "index_images_on_user_id", using: :btree

  create_table "looks", force: true do |t|
    t.text     "title"
    t.text     "short_desc"
    t.text     "desc"
    t.text     "usage_directions"
    t.integer  "user_id"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "looks", ["user_id"], name: "index_looks_on_user_id", using: :btree

  create_table "product_apps", force: true do |t|
    t.integer  "role",       null: false
    t.integer  "product_id", null: false
    t.integer  "user_id"
    t.integer  "category",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_apps", ["product_id"], name: "index_product_apps_on_product_id", using: :btree
  add_index "product_apps", ["user_id"], name: "index_product_apps_on_user_id", using: :btree

  create_table "product_clusters", force: true do |t|
    t.text     "category",       null: false
    t.text     "role",           null: false
    t.integer  "user_id"
    t.integer  "product_set_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_clusters", ["product_set_id", "category", "role"], name: "index_product_clusters_on_product_set_id_and_category_and_role", unique: true, using: :btree
  add_index "product_clusters", ["product_set_id"], name: "index_product_clusters_on_product_set_id", using: :btree
  add_index "product_clusters", ["user_id"], name: "index_product_clusters_on_user_id", using: :btree

  create_table "product_recommendations", force: true do |t|
    t.integer  "product_cluster_id",              null: false
    t.integer  "product_app_id",                  null: false
    t.integer  "priority",           default: 50, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_recommendations", ["product_app_id"], name: "index_product_recommendations_on_product_app_id", using: :btree
  add_index "product_recommendations", ["product_cluster_id"], name: "index_product_recommendations_on_product_cluster_id", using: :btree

  create_table "product_reviews", force: true do |t|
    t.text     "title",       null: false
    t.integer  "rating"
    t.boolean  "recommended"
    t.boolean  "use_again"
    t.text     "review"
    t.integer  "product_id"
    t.integer  "user_id"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_reviews", ["product_id"], name: "index_product_reviews_on_product_id", using: :btree
  add_index "product_reviews", ["user_id"], name: "index_product_reviews_on_user_id", using: :btree

  create_table "product_sets", force: true do |t|
    t.integer  "look_id",    null: false
    t.text     "skin_color", null: false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_sets", ["look_id"], name: "index_product_sets_on_look_id", using: :btree
  add_index "product_sets", ["user_id"], name: "index_product_sets_on_user_id", using: :btree

  create_table "products", force: true do |t|
    t.text     "sku",                        null: false
    t.text     "brand"
    t.text     "line"
    t.text     "name"
    t.text     "shade_name"
    t.text     "shade_code"
    t.text     "short_desc"
    t.text     "desc"
    t.integer  "image_usage_id"
    t.text     "hex_color_val"
    t.boolean  "active"
    t.integer  "price_cents",    default: 0, null: false
    t.integer  "cost_cents"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", force: true do |t|
    t.text     "first_name"
    t.text     "last_name"
    t.text     "email"
    t.text     "street1"
    t.text     "street2"
    t.text     "city"
    t.text     "state"
    t.text     "postal_code"
    t.boolean  "receive_emails", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source"
    t.integer  "user_id"
    t.string   "skin_color"
    t.string   "eye_color"
    t.string   "hair_color"
    t.string   "age"
    t.string   "skin_type"
    t.text     "img_filename"
  end

  add_index "profiles", ["email"], name: "index_profiles_on_email", unique: true, using: :btree
  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.text     "email",                  default: "", null: false
    t.text     "encrypted_password",     default: "", null: false
    t.text     "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.text     "current_sign_in_ip"
    t.text     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "role"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "video_usages", force: true do |t|
    t.text     "page"
    t.text     "role"
    t.integer  "video_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "video_usages", ["video_id"], name: "index_video_usages_on_video_id", using: :btree

  create_table "videos", force: true do |t|
    t.text     "name"
    t.integer  "size"
    t.string   "duration",   limit: nil
    t.text     "filename"
    t.text     "dimensions"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "videos", ["user_id"], name: "index_videos_on_user_id", using: :btree

end
