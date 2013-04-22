class CreateAccountDataImportRows < ActiveRecord::Migration
  def change
    create_table :account_data_import_rows do |t|
      t.primary_key :id
      t.integer     :lock_version,  :default => 0
      t.timestamps
                                                    # Adds the current data-import session unique identifier:
      t.references :account_data_import_session
                                                    # Pre-parsing multi-usage data columns:
      t.string :string_1
      t.string :string_2
      t.string :string_3
      t.string :string_4
      t.string :string_5
      t.date :date_1
      t.date :date_2
      t.integer :int_1
      t.integer :int_2
      t.float :float_1
      t.text :text_1
      t.text :text_2
                                                    # This will have a value != 0 only if a conflicting row id was found during the parsing phase
      t.integer   :conflicting_account_row_id,    :limit => 8, :default => 0
                                                    # These will store the destination column values after the parsing:
      t.integer   :account_id,                    :limit => 8
      t.integer   :user_id,                       :limit => 8
      t.datetime  :date_entry
      t.decimal   :entry_value,     :precision => 10, :scale => 2, :default => 0.0
      t.integer   :le_currency_id,                :limit => 8
      t.string    :description
      t.integer   :recipient_firm_id,             :limit => 8
      t.integer   :parent_le_account_row_type_id, :limit => 8
      t.integer   :le_account_row_type_id,        :limit => 8
      t.integer   :le_account_payment_type_id,    :limit => 8
      t.string    :check_number,                  :limit => 80
      t.text      :notes
    end

    add_index :account_data_import_rows, ["account_data_import_session_id"], :name => "account_data_import_session_id"
    add_index :account_data_import_rows, ["conflicting_account_row_id"], :name => "conflicting_account_row_id"

    add_index :account_data_import_rows, ["account_id"], :name => "account_id"
    add_index :account_data_import_rows, ["date_entry"], :name => "date_entry"
    add_index :account_data_import_rows, ["le_account_payment_type_id"], :name => "le_payment_type_id"
    add_index :account_data_import_rows, ["le_account_row_type_id"], :name => "le_account_row_type_id"
    add_index :account_data_import_rows, ["le_currency_id"], :name => "le_currency_id"
    add_index :account_data_import_rows, ["parent_le_account_row_type_id"], :name => "parent_le_account_row_type_id"
    add_index :account_data_import_rows, ["recipient_firm_id"], :name => "recipient_firm_id"
    add_index :account_data_import_rows, ["user_id"], :name => "user_id"
  end
end
