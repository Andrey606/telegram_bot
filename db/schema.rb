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

ActiveRecord::Schema.define(version: 2022_02_06_152011) do

  create_table "dictionaries", force: :cascade do |t|
    t.string "word"
    t.string "translation"
    t.string "parts_of_speech"
    t.string "level"
    t.json "examples"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "document_dictionaries", force: :cascade do |t|
    t.integer "document_id", null: false
    t.integer "dictionary_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dictionary_id"], name: "index_document_dictionaries_on_dictionary_id"
    t.index ["document_id"], name: "index_document_dictionaries_on_document_id"
  end

  create_table "documents", force: :cascade do |t|
    t.string "file_name"
    t.string "mime_type"
    t.string "file_id"
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "user_words", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "dictionary_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dictionary_id"], name: "index_user_words_on_dictionary_id"
    t.index ["user_id"], name: "index_user_words_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.integer "telegram_id"
    t.integer "step"
    t.string "chat_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "words_per_week"
    t.integer "document_id"
    t.index ["document_id"], name: "index_users_on_document_id"
  end

  add_foreign_key "document_dictionaries", "dictionaries"
  add_foreign_key "document_dictionaries", "documents"
  add_foreign_key "documents", "users"
  add_foreign_key "user_words", "dictionaries"
  add_foreign_key "user_words", "users"
end
