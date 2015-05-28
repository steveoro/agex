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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150528114800) do

  create_table "account_data_import_rows", :force => true do |t|
    t.integer  "lock_version",                                                                :default => 0
    t.datetime "created_at",                                                                                   :null => false
    t.datetime "updated_at",                                                                                   :null => false
    t.integer  "account_data_import_session_id"
    t.string   "string_1"
    t.string   "string_2"
    t.string   "string_3"
    t.string   "string_4"
    t.string   "string_5"
    t.date     "date_1"
    t.date     "date_2"
    t.integer  "int_1"
    t.integer  "int_2"
    t.float    "float_1"
    t.text     "text_1"
    t.text     "text_2"
    t.integer  "conflicting_account_row_id",     :limit => 8,                                 :default => 0
    t.integer  "account_id",                     :limit => 8
    t.integer  "user_id",                        :limit => 8
    t.datetime "date_entry"
    t.decimal  "entry_value",                                  :precision => 10, :scale => 2, :default => 0.0
    t.integer  "le_currency_id",                 :limit => 8
    t.string   "description"
    t.integer  "recipient_firm_id",              :limit => 8
    t.integer  "parent_le_account_row_type_id",  :limit => 8
    t.integer  "le_account_row_type_id",         :limit => 8
    t.integer  "le_account_payment_type_id",     :limit => 8
    t.string   "check_number",                   :limit => 80
    t.text     "notes"
  end

  add_index "account_data_import_rows", ["account_data_import_session_id"], :name => "account_data_import_session_id"
  add_index "account_data_import_rows", ["account_id"], :name => "account_id"
  add_index "account_data_import_rows", ["conflicting_account_row_id"], :name => "conflicting_account_row_id"
  add_index "account_data_import_rows", ["date_entry"], :name => "date_entry"
  add_index "account_data_import_rows", ["le_account_payment_type_id"], :name => "le_payment_type_id"
  add_index "account_data_import_rows", ["le_account_row_type_id"], :name => "le_account_row_type_id"
  add_index "account_data_import_rows", ["le_currency_id"], :name => "le_currency_id"
  add_index "account_data_import_rows", ["parent_le_account_row_type_id"], :name => "parent_le_account_row_type_id"
  add_index "account_data_import_rows", ["recipient_firm_id"], :name => "recipient_firm_id"
  add_index "account_data_import_rows", ["user_id"], :name => "user_id"

  create_table "account_data_import_sessions", :force => true do |t|
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "file_name"
    t.text     "source_data"
    t.integer  "phase"
    t.integer  "user_id"
    t.integer  "total_data_rows"
    t.string   "file_format"
    t.text     "phase_1_log"
    t.text     "phase_2_log"
    t.text     "phase_3_log"
  end

  add_index "account_data_import_sessions", ["user_id"], :name => "user_id"

  create_table "account_rows", :force => true do |t|
    t.integer   "lock_version",                                                               :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                                                                  :null => false
    t.integer   "account_id",                    :limit => 8,                                                  :null => false
    t.integer   "user_id",                       :limit => 8
    t.datetime  "date_entry",                                                                                  :null => false
    t.decimal   "entry_value",                                 :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.integer   "le_currency_id",                :limit => 8
    t.string    "description",                                                                                 :null => false
    t.integer   "recipient_firm_id",             :limit => 8
    t.integer   "parent_le_account_row_type_id", :limit => 8
    t.integer   "le_account_row_type_id",        :limit => 8
    t.integer   "le_account_payment_type_id",    :limit => 8
    t.string    "check_number",                  :limit => 80
    t.text      "notes"
  end

  add_index "account_rows", ["account_id"], :name => "account_id"
  add_index "account_rows", ["date_entry"], :name => "date_entry"
  add_index "account_rows", ["le_account_payment_type_id"], :name => "le_payment_type_id"
  add_index "account_rows", ["le_account_row_type_id"], :name => "le_account_row_type_id"
  add_index "account_rows", ["le_currency_id"], :name => "le_currency_id"
  add_index "account_rows", ["parent_le_account_row_type_id"], :name => "parent_le_account_row_type_id"
  add_index "account_rows", ["recipient_firm_id"], :name => "recipient_firm_id"
  add_index "account_rows", ["user_id"], :name => "user_id"

  create_table "accounts", :force => true do |t|
    t.integer   "lock_version",               :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                :null => false
    t.string    "name",         :limit => 20,                :null => false
    t.string    "description",  :limit => 80
    t.integer   "firm_id",      :limit => 8,                 :null => false
  end

  add_index "accounts", ["firm_id"], :name => "firm_id"
  add_index "accounts", ["name"], :name => "name"

  create_table "app_parameters", :force => true do |t|
    t.integer  "code",                                                          :default => 0,     :null => false
    t.integer  "lock_version",                                                  :default => 0
    t.datetime "created_on"
    t.datetime "updated_on",                                                                       :null => false
    t.string   "controller_name"
    t.string   "action_name"
    t.boolean  "is_a_post",                                                     :default => false, :null => false
    t.string   "confirmation_text"
    t.string   "a_string"
    t.boolean  "a_bool",                                                        :default => false, :null => false
    t.integer  "a_integer",         :limit => 8
    t.datetime "a_date"
    t.decimal  "a_decimal",                      :precision => 10, :scale => 2
    t.decimal  "a_decimal_2",                    :precision => 10, :scale => 2
    t.decimal  "a_decimal_3",                    :precision => 10, :scale => 2
    t.decimal  "a_decimal_4",                    :precision => 10, :scale => 2
    t.integer  "range_x",           :limit => 8
    t.integer  "range_y",           :limit => 8
    t.string   "a_name"
    t.string   "a_filename"
    t.string   "tooltip_text"
    t.integer  "view_height",                                                   :default => 0,     :null => false
    t.integer  "code_type_1",       :limit => 8
    t.integer  "code_type_2",       :limit => 8
    t.integer  "code_type_3",       :limit => 8
    t.integer  "code_type_4",       :limit => 8
    t.text     "free_text_1"
    t.text     "free_text_2"
    t.text     "free_text_3"
    t.text     "free_text_4"
    t.boolean  "free_bool_1"
    t.boolean  "free_bool_2"
    t.boolean  "free_bool_3"
    t.boolean  "free_bool_4"
    t.boolean  "free_bool_5"
    t.boolean  "free_bool_6"
    t.text     "description"
  end

  add_index "app_parameters", ["code"], :name => "code", :unique => true

  create_table "articles", :force => true do |t|
    t.integer   "lock_version",               :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                    :null => false
    t.string    "title",        :limit => 80,                    :null => false
    t.text      "entry_text",                                    :null => false
    t.integer   "user_id",      :limit => 8,                     :null => false
    t.boolean   "is_sticky",                  :default => false, :null => false
  end

  add_index "articles", ["title"], :name => "name"
  add_index "articles", ["user_id"], :name => "user_id"

  create_table "contacts", :force => true do |t|
    t.integer   "lock_version",                      :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                           :null => false
    t.integer   "le_title_id",        :limit => 8
    t.string    "name",               :limit => 40,                     :null => false
    t.string    "surname",            :limit => 80,  :default => "",    :null => false
    t.integer   "le_contact_type_id", :limit => 8
    t.string    "address"
    t.integer   "le_city_id",         :limit => 8
    t.string    "tax_code",           :limit => 18
    t.string    "vat_registration",   :limit => 20
    t.datetime  "date_birth"
    t.string    "phone_home",         :limit => 40
    t.string    "phone_work",         :limit => 40
    t.string    "phone_cell",         :limit => 40
    t.string    "phone_fax",          :limit => 40
    t.string    "e_mail",             :limit => 100
    t.text      "notes"
    t.text      "personal_notes"
    t.text      "family_notes"
    t.datetime  "date_last_met"
    t.integer   "firm_id",            :limit => 8
    t.boolean   "is_suspended",                      :default => false, :null => false
  end

  add_index "contacts", ["firm_id"], :name => "firm_id"
  add_index "contacts", ["le_city_id"], :name => "le_city_id"
  add_index "contacts", ["le_contact_type_id"], :name => "le_contact_type_id"
  add_index "contacts", ["le_title_id"], :name => "le_title_id"
  add_index "contacts", ["name", "surname"], :name => "name_surname"
  add_index "contacts", ["surname", "name"], :name => "surname_name"

  create_table "firms", :force => true do |t|
    t.integer   "lock_version",                              :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                                   :null => false
    t.string    "name",                       :limit => 80,                     :null => false
    t.string    "address"
    t.integer   "le_city_id",                 :limit => 8
    t.string    "tax_code",                   :limit => 18
    t.string    "vat_registration",           :limit => 20
    t.string    "phone_main",                 :limit => 40
    t.string    "phone_hq",                   :limit => 40
    t.string    "phone_fax",                  :limit => 40
    t.string    "e_mail",                     :limit => 100
    t.boolean   "is_user",                                   :default => false, :null => false
    t.boolean   "is_committer",                              :default => false, :null => false
    t.boolean   "is_partner",                                :default => false, :null => false
    t.boolean   "is_vendor",                                 :default => false, :null => false
    t.text      "notes"
    t.string    "bank_name",                  :limit => 80
    t.string    "bank_cc",                    :limit => 40
    t.integer   "le_currency_id",             :limit => 8
    t.string    "bank_abicab",                :limit => 80
    t.text      "bank_notes"
    t.boolean   "is_out_of_business",                        :default => false, :null => false
    t.string    "logo_image_big"
    t.string    "logo_image_short"
    t.integer   "le_invoice_payment_type_id", :limit => 8
  end

  add_index "firms", ["le_city_id"], :name => "le_city_id"
  add_index "firms", ["le_currency_id"], :name => "le_currency_id"
  add_index "firms", ["le_invoice_payment_type_id"], :name => "le_invoice_payment_type_id"
  add_index "firms", ["name"], :name => "name"

  create_table "human_resources", :force => true do |t|
    t.integer   "lock_version",                                                       :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                                                            :null => false
    t.integer   "contact_id",            :limit => 8,                                                    :null => false
    t.integer   "le_resource_type_id",   :limit => 8
    t.string    "name",                  :limit => 40,                                                   :null => false
    t.string    "description",           :limit => 80
    t.string    "notes"
    t.datetime  "date_start"
    t.integer   "le_currency_id",        :limit => 8
    t.decimal   "cost_std_hour",                       :precision => 10, :scale => 2, :default => 0.0,   :null => false
    t.decimal   "cost_ext_hour",                       :precision => 10, :scale => 2, :default => 0.0,   :null => false
    t.decimal   "cost_km",                             :precision => 10, :scale => 2, :default => 0.0,   :null => false
    t.decimal   "charge_std_hour",                     :precision => 10, :scale => 2, :default => 0.0,   :null => false
    t.decimal   "charge_ext_hour",                     :precision => 10, :scale => 2, :default => 0.0,   :null => false
    t.decimal   "fixed_weekly_wage",                   :precision => 10, :scale => 2, :default => 0.0,   :null => false
    t.decimal   "charge_weekly_wage",                  :precision => 10, :scale => 2, :default => 0.0,   :null => false
    t.decimal   "percentage_of_invoice",               :precision => 10, :scale => 2, :default => 0.0,   :null => false
    t.boolean   "is_no_more_available",                                               :default => false, :null => false
  end

  add_index "human_resources", ["contact_id"], :name => "le_contact_id"
  add_index "human_resources", ["le_currency_id"], :name => "le_currency_id"
  add_index "human_resources", ["le_resource_type_id"], :name => "le_resource_type_id"
  add_index "human_resources", ["name"], :name => "name"

  create_table "invoice_rows", :force => true do |t|
    t.integer   "lock_version",                                                       :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                                                          :null => false
    t.integer   "invoice_id",             :limit => 8,                                                 :null => false
    t.integer   "project_id",             :limit => 8
    t.string    "description",                                                                         :null => false
    t.decimal   "quantity",                            :precision => 10, :scale => 2, :default => 1.0, :null => false
    t.integer   "le_invoice_row_unit_id", :limit => 8
    t.decimal   "unit_cost",                           :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.integer   "le_currency_id",         :limit => 8
    t.decimal   "vat_tax",                             :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.decimal   "discount",                            :precision => 10, :scale => 2, :default => 0.0, :null => false
  end

  add_index "invoice_rows", ["invoice_id"], :name => "invoice_id"
  add_index "invoice_rows", ["le_currency_id"], :name => "le_currency_id"
  add_index "invoice_rows", ["le_invoice_row_unit_id"], :name => "le_invoice_row_unit_id"
  add_index "invoice_rows", ["project_id"], :name => "project_id"

  create_table "invoices", :force => true do |t|
    t.integer   "lock_version",                                                            :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                                                                 :null => false
    t.string    "name",                       :limit => 40,                                                   :null => false
    t.string    "description",                :limit => 80
    t.integer   "firm_id",                    :limit => 8,                                                    :null => false
    t.integer   "recipient_firm_id",          :limit => 8,                                                    :null => false
    t.integer   "invoice_number",                                                                             :null => false
    t.datetime  "date_invoice",                                                                               :null => false
    t.string    "header_object",                                                                              :null => false
    t.boolean   "is_fully_payed",                                                          :default => false, :null => false
    t.decimal   "social_security_cost",                     :precision => 10, :scale => 2, :default => 0.0,   :null => false
    t.decimal   "vat_tax",                                  :precision => 10, :scale => 2, :default => 0.0,   :null => false
    t.decimal   "account_wage",                             :precision => 10, :scale => 2, :default => 0.0,   :null => false
    t.decimal   "total_expenses",                           :precision => 10, :scale => 2, :default => 0.0,   :null => false
    t.integer   "le_currency_id",             :limit => 8
    t.integer   "le_invoice_payment_type_id", :limit => 8
    t.text      "notes"
    t.integer   "invoice_type_id",                                                         :default => 0,     :null => false
  end

  add_index "invoices", ["date_invoice", "invoice_number"], :name => "invoice_number"
  add_index "invoices", ["firm_id"], :name => "firm_id"
  add_index "invoices", ["invoice_type_id"], :name => "invoice_type_id"
  add_index "invoices", ["le_currency_id"], :name => "le_currency_id"
  add_index "invoices", ["le_invoice_payment_type_id"], :name => "le_invoice_payment_type_id"
  add_index "invoices", ["name"], :name => "name"
  add_index "invoices", ["recipient_firm_id"], :name => "recipient_firm_id"

  create_table "le_account_payment_types", :force => true do |t|
    t.integer   "lock_version",               :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                :null => false
    t.string    "name",         :limit => 20,                :null => false
  end

  add_index "le_account_payment_types", ["name"], :name => "name"

  create_table "le_account_row_types", :force => true do |t|
    t.integer   "lock_version",               :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                    :null => false
    t.string    "name",         :limit => 40,                    :null => false
    t.boolean   "is_a_parent",                :default => false, :null => false
  end

  add_index "le_account_row_types", ["is_a_parent"], :name => "is_a_parent"
  add_index "le_account_row_types", ["name"], :name => "name"

  create_table "le_cities", :force => true do |t|
    t.integer   "lock_version",               :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                :null => false
    t.string    "name",         :limit => 40,                :null => false
    t.string    "zip",          :limit => 6
    t.string    "area",         :limit => 40,                :null => false
    t.string    "country",      :limit => 40,                :null => false
    t.string    "country_code", :limit => 4,                 :null => false
  end

  add_index "le_cities", ["name"], :name => "name"
  add_index "le_cities", ["zip"], :name => "zip"

  create_table "le_contact_types", :force => true do |t|
    t.integer   "lock_version",               :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                :null => false
    t.string    "name",         :limit => 20,                :null => false
  end

  add_index "le_contact_types", ["name"], :name => "name"

  create_table "le_currencies", :force => true do |t|
    t.integer   "lock_version",                 :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                           :null => false
    t.string    "name",           :limit => 20,                         :null => false
    t.string    "description",    :limit => 80
    t.string    "display_symbol", :limit => 10,                         :null => false
    t.string    "value_format",   :limit => 20, :default => "#,##0.00", :null => false
  end

  add_index "le_currencies", ["name"], :name => "name"

  create_table "le_currency_exchange", :force => true do |t|
    t.integer   "lock_version",                                                        :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                                                           :null => false
    t.integer   "source_currency_id",      :limit => 8,                                                 :null => false
    t.integer   "destination_currency_id", :limit => 8,                                                 :null => false
    t.datetime  "date_exchange",                                                                        :null => false
    t.decimal   "factor",                               :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.string    "comment"
  end

  create_table "le_invoice_payment_types", :force => true do |t|
    t.integer   "lock_version",               :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                :null => false
    t.string    "name",         :limit => 40,                :null => false
  end

  add_index "le_invoice_payment_types", ["name"], :name => "name"

  create_table "le_invoice_row_units", :force => true do |t|
    t.integer   "lock_version",               :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                :null => false
    t.string    "name",         :limit => 20,                :null => false
  end

  add_index "le_invoice_row_units", ["name"], :name => "name"

  create_table "le_resource_types", :force => true do |t|
    t.integer   "lock_version",               :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                :null => false
    t.string    "name",         :limit => 20,                :null => false
    t.string    "description",  :limit => 80
  end

  add_index "le_resource_types", ["name"], :name => "name"

  create_table "le_titles", :force => true do |t|
    t.integer   "lock_version",               :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                :null => false
    t.string    "name",         :limit => 20,                :null => false
    t.string    "description",  :limit => 80
  end

  add_index "le_titles", ["name"], :name => "name"

  create_table "le_users", :force => true do |t|
    t.integer   "lock_version",                       :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                            :null => false
    t.string    "name",                :limit => 20,  :default => "",    :null => false
    t.string    "description",         :limit => 80
    t.string    "hashed_pwd",          :limit => 128,                    :null => false
    t.string    "salt",                :limit => 128,                    :null => false
    t.boolean   "enable_delete",                      :default => false, :null => false
    t.boolean   "enable_edit",                        :default => false, :null => false
    t.boolean   "enable_setup",                       :default => false, :null => false
    t.boolean   "enable_blog",                        :default => false, :null => false
    t.integer   "authorization_level",                :default => 0,     :null => false
    t.integer   "firm_id",             :limit => 8
  end

  add_index "le_users", ["firm_id"], :name => "firm_id"
  add_index "le_users", ["name"], :name => "name"

  create_table "project_milestones", :force => true do |t|
    t.integer   "lock_version",                         :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                              :null => false
    t.integer   "project_id",             :limit => 8,                     :null => false
    t.integer   "user_id",                :limit => 8
    t.integer   "human_resource_id",      :limit => 8
    t.integer   "depends_on_id",          :limit => 8
    t.integer   "esteemed_days",                        :default => 1,     :null => false
    t.date      "date_esteemed"
    t.string    "projected_for_version",  :limit => 40
    t.boolean   "is_public",                            :default => false, :null => false
    t.boolean   "is_critical",                          :default => false, :null => false
    t.boolean   "is_urgent",                            :default => false, :null => false
    t.boolean   "is_structural",                        :default => false, :null => false
    t.boolean   "is_user_request",                      :default => true,  :null => false
    t.string    "name",                   :limit => 40,                    :null => false
    t.string    "module_names"
    t.date      "date_implemented"
    t.string    "implemented_in_version", :limit => 40
    t.text      "description"
    t.text      "notes"
  end

  add_index "project_milestones", ["depends_on_id"], :name => "depends_on_id"
  add_index "project_milestones", ["human_resource_id"], :name => "human_resource_id"
  add_index "project_milestones", ["implemented_in_version"], :name => "implemented_in_version"
  add_index "project_milestones", ["name"], :name => "name"
  add_index "project_milestones", ["project_id"], :name => "project_id"
  add_index "project_milestones", ["projected_for_version"], :name => "projected_for_version"
  add_index "project_milestones", ["user_id"], :name => "user_id"

  create_table "project_rows", :force => true do |t|
    t.integer   "lock_version",                                                     :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                                                          :null => false
    t.integer   "project_id",           :limit => 8,                                                   :null => false
    t.integer   "human_resource_id",    :limit => 8
    t.datetime  "date_entry",                                                                          :null => false
    t.integer   "std_hours",                                                        :default => 0,     :null => false
    t.integer   "ext_hours",                                                        :default => 0,     :null => false
    t.integer   "km_tot",                                                           :default => 0,     :null => false
    t.decimal   "extra_expenses",                    :precision => 10, :scale => 2, :default => 0.0,   :null => false
    t.integer   "le_currency_id",       :limit => 8
    t.boolean   "is_analysis",                                                      :default => false, :null => false
    t.boolean   "is_development",                                                   :default => false, :null => false
    t.boolean   "is_deployment",                                                    :default => false, :null => false
    t.integer   "project_milestone_id", :limit => 8
    t.boolean   "is_debug",                                                         :default => false, :null => false
    t.boolean   "is_setup",                                                         :default => false, :null => false
    t.boolean   "is_study",                                                         :default => false, :null => false
    t.text      "description"
    t.text      "notes"
  end

  add_index "project_rows", ["date_entry"], :name => "date_entry"
  add_index "project_rows", ["human_resource_id"], :name => "human_resource_id"
  add_index "project_rows", ["le_currency_id"], :name => "le_currency_id"
  add_index "project_rows", ["project_id"], :name => "project_id"
  add_index "project_rows", ["project_milestone_id"], :name => "project_milestone_id"

  create_table "projects", :force => true do |t|
    t.integer   "lock_version",                                                   :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                                                        :null => false
    t.integer   "project_id",        :limit => 8
    t.string    "codename",          :limit => 20,                                                   :null => false
    t.string    "name",              :limit => 40,                                                   :null => false
    t.text      "description"
    t.text      "notes"
    t.integer   "firm_id",           :limit => 8
    t.integer   "partner_firm_id",   :limit => 8
    t.integer   "committer_firm_id", :limit => 8
    t.decimal   "esteemed_price",                  :precision => 10, :scale => 2, :default => 0.0,   :null => false
    t.integer   "le_currency_id",    :limit => 8
    t.integer   "team_id",           :limit => 8
    t.datetime  "date_start",                                                                        :null => false
    t.datetime  "date_end"
    t.boolean   "has_gone_gold",                                                  :default => false, :null => false
    t.boolean   "is_closed",                                                      :default => false, :null => false
    t.boolean   "has_been_invoiced",                                              :default => false, :null => false
    t.boolean   "is_a_demo",                                                      :default => false, :null => false
  end

  add_index "projects", ["committer_firm_id"], :name => "committer_firm_id"
  add_index "projects", ["firm_id"], :name => "user_firm_id"
  add_index "projects", ["le_currency_id"], :name => "le_currency_id"
  add_index "projects", ["name"], :name => "name"
  add_index "projects", ["partner_firm_id"], :name => "partner_firm_id"
  add_index "projects", ["project_id"], :name => "project_id"
  add_index "projects", ["team_id"], :name => "team_id"

  create_table "sessions", :force => true do |t|
    t.integer   "lock_version", :default => 0
    t.string    "session_id"
    t.text      "data"
    t.datetime  "created_on"
    t.timestamp "updated_on",                  :null => false
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "team_rows", :force => true do |t|
    t.integer   "lock_version",                   :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                    :null => false
    t.integer   "team_id",           :limit => 8,                :null => false
    t.integer   "human_resource_id", :limit => 8,                :null => false
  end

  add_index "team_rows", ["human_resource_id"], :name => "human_resource_id"
  add_index "team_rows", ["team_id"], :name => "team_id"

  create_table "teams", :force => true do |t|
    t.integer   "lock_version",                       :default => 0
    t.datetime  "created_on"
    t.timestamp "updated_on",                                            :null => false
    t.string    "name",                 :limit => 20,                    :null => false
    t.string    "description",          :limit => 80
    t.integer   "firm_id",              :limit => 8
    t.boolean   "is_no_more_available",               :default => false
  end

  add_index "teams", ["firm_id"], :name => "firm_id"
  add_index "teams", ["name"], :name => "name"

end
