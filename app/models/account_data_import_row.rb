class AccountDataImportRow < ActiveRecord::Base

  belongs_to :account_data_import_session

  belongs_to :account_row, :foreign_key => "conflicting_account_row_id"

  belongs_to :account
  belongs_to :le_currency
  belongs_to :le_account_payment_type

  belongs_to :user,           :class_name => "LeUser",
                              :foreign_key => "user_id"

  belongs_to :recipient_firm, :class_name  => "Firm", 
                              :foreign_key => "recipient_firm_id"
                              # Note that if we get too specific with conditions here, ActiveRecords nils out the associations
                              # rows that do not respond to the constraints, as in the case of having a non-vendor id nulled specifing
                              # for example :conditions => "((firms.is_committer = 1) or (firms.is_vendor = 1))".
                              # To filter out rows see the ActiveScaffold association conditions override in the Helper file.
  belongs_to :parent_le_account_row_type,
            :class_name => "LeAccountRowType", :foreign_key => "parent_le_account_row_type_id",
            :conditions  => { :is_a_parent => true }

  belongs_to :le_account_row_type,
            :class_name => "LeAccountRowType", :foreign_key => "le_account_row_type_id",
            :conditions  => { :is_a_parent => false }

  validates_associated :account_data_import_session


  # [20121101] Note that the following (and all the subsequent scoping definitions) works only with
  # Netzke components, as value for :scope (when le_currency is an association column) and with
  # :sorting_scope (when a field of le_currency is the column to be sorted).
  # Mind also that the parametric scopes are used only in :sorting_scope, not in :scope, so this will
  # actually work only:
  # - inside a Netzke component using this model
  # - as value for the :sorting_scope
  #
  scope :netzke_sort_data_import_currencies_by_display_symbol,    lambda { |dir| order("le_currencies.display_symbol #{dir.to_s}") }

  scope :netzke_sort_data_import_users_row_by_name,               lambda { |dir| order("le_users.name #{dir.to_s}") }
  scope :netzke_sort_data_import_parent_row_types_by_name,        lambda { |dir| order("le_account_row_types.name #{dir.to_s}") }
  scope :netzke_sort_data_import_row_types_by_name,               lambda { |dir| order("le_account_row_types_account_data_import_rows.name #{dir.to_s}") }
  scope :netzke_sort_data_import_payment_types_by_name,           lambda { |dir| order("le_account_payment_types.name #{dir.to_s}") }
  scope :netzke_sort_data_import_recipient_firm_by_name,          lambda { |dir| order("firms.name #{dir.to_s}") }

  scope :netzke_sort_data_import_conflicting_rows_id,             lambda { |dir| order("conflicting_account_row_id #{dir.to_s}") }
  # ---------------------------------------------------------------------------


  # Computes a verbose or formal description for the account row data "conflicting" with the current import data row
  def get_verbose_conflicting_account_row
    if ( self.conflicting_account_row_id.to_i > 0 )
      begin
        conflicting_row = AccountRow.find( conflicting_account_row_id )
        "(ID:#{conflicting_account_row_id}) #{Format.a_date(conflicting_row.date_entry)}: #{conflicting_row.entry_value} #{conflicting_row.get_currency_symbol()}, #{conflicting_row.description}"
      rescue
        "(ID:#{conflicting_account_row_id}) <#{I18n.t(:unable_to_retrieve_account_row_data, :scope =>[:account_row] )}>"
      end
    else
      ''
    end
  end
  # ---------------------------------------------------------------------------

end
