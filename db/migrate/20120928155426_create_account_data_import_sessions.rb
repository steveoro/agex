class CreateAccountDataImportSessions < ActiveRecord::Migration
  def change
    create_table :account_data_import_sessions do |t|
      t.primary_key :id
      t.timestamps
      t.string :file_name
      t.text :source_data
      t.integer :phase
      t.integer :user_id
      t.integer :total_data_rows
      t.string :file_format
      t.text :phase_1_log
      t.text :phase_2_log
      t.text :phase_3_log
    end

    add_index :account_data_import_sessions, ["user_id"], :name => "user_id"
  end
end
