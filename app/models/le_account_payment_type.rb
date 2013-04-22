class LeAccountPaymentType < ActiveRecord::Base

  validates_presence_of :name
  validates_length_of :name, :within => 1..20
  validates_uniqueness_of :name, :message => :already_exists
  # ----------------------------------------------------------------------------
  #++

  # Computes a shorter (but full) representative value of this instance's data.
  #
  def get_full_name()
    self.name.to_s
  end
  # ----------------------------------------------------------------------------


  # Helper references to pre-stored row seeds, used by "custom actions"
  ID_FOR_CASH = 1
  ID_FOR_CREDIT_CARD = 2
  ID_FOR_DEBIT_CARD = 3
  ID_FOR_CHECK = 4
  ID_FOR_MONEY_TRASFER = 5
  ID_FOR_ACCOUNT_DEBIT = 6
  ID_FOR_ACCOUNT_CREDIT = 7
  # ----------------------------------------------------------------------------
end
