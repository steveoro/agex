class AccountDataImportSession < ActiveRecord::Base
  has_many :account_data_import_rows
end
