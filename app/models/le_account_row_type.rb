class LeAccountRowType < ActiveRecord::Base
  validates_presence_of :name
  validates_length_of :name, :within => 1..40
  validates_uniqueness_of :name, :message => :already_exists

  # Note: boolean validation via a typical...
  #
  #   validates_format_of :is_a_parent_before_type_cast, :with => /[01]/, :message=> :must_be_0_or_1
  #
  # ...must *not* be used since the ExtJS grids convert internally the values from string/JSON text.

  scope :all_parent_types, where(:is_a_parent => true)
  scope :all_normal_types, where(:is_a_parent => false)
  # ----------------------------------------------------------------------------
  #++

  # Computes a shorter (but full) representative value of this instance's data.
  #
  def get_full_name()
    self.name.to_s
  end
  # ----------------------------------------------------------------------------


  # Helper references to pre-stored row seeds, used by "custom actions", Parent types:
  ID_FOR_COSTS = 1
  ID_FOR_PROFITS = 2
  ID_FOR_INVESTMENTS = 3
  ID_FOR_TAXES = 4
  ID_FOR_OWNER_LOAN_RETURNS = 5
  ID_FOR_OWNER_WITHDRAWALS = 6
  ID_FOR_PAYCHECK = 7
  ID_FOR_CASH_DEPOSIT = 19
  ID_FOR_INTERESTS = 37
  ID_FOR_INVEST_WITHDRAWALS = 39


  # Helper references to pre-stored row seeds, used by "custom actions", standard types:
  ID_FOR_TELEPHONE = 8
  ID_FOR_GASOLINE = 9
  ID_FOR_FREEWAY = 10
  ID_FOR_LIBRARY = 14
  ID_FOR_INVOICING = 15
  ID_FOR_CASH_LOAN_BY_OWNER = 16
  ID_FOR_COMMODITY_SERVICES = 22
  ID_FOR_AUTOS = 23
  ID_FOR_GROCERIES = 24
  ID_FOR_MISC = 26
  ID_FOR_BIO_GROCERIES = 27
  ID_FOR_CONDO_EXPENSES = 28
  ID_FOR_INCOMES_STEVE = 29
  ID_FOR_INCOMES_BABY = 30
  ID_FOR_LUNCH_DINNER_OUT = 31
  ID_FOR_XDSL_SERVICES = 33
  ID_FOR_BANK_SERVICES = 34
  # ----------------------------------------------------------------------------
end
