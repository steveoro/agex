require 'common/format'


class HumanResource < ActiveRecord::Base

  belongs_to :le_resource_type
  belongs_to :le_currency
  belongs_to :contact

  has_many :team_rows
  has_many :teams, :through => :team_rows

  validates_associated :le_currency
  validates_associated :le_resource_type
  validates_associated :contact

  validates_presence_of :name
  validates_length_of :name, :within => 1..40
  validates_uniqueness_of :name, :message => :already_exists

  validates_length_of :description, :maximum => 80, :allow_nil => true

  validates_length_of :notes, :maximum => 255, :allow_nil => true

  validates_numericality_of :cost_std_hour
  validates_numericality_of :cost_ext_hour
  validates_numericality_of :cost_km
  validates_numericality_of :charge_std_hour
  validates_numericality_of :charge_ext_hour
  validates_numericality_of :fixed_weekly_wage
  validates_numericality_of :charge_weekly_wage
  validates_numericality_of :percentage_of_invoice

  #--
  # Note: boolean validation via a typical...
  #
  #   validates_format_of :is_no_more_available_before_type_cast, :with => /[01]/, :message=> :must_be_0_or_1
  #
  # ...must *not* be used since the ExtJS grids convert internally the values from string/JSON text.


  scope :still_available, where(:is_no_more_available => false)

  scope :sort_resource_by_contact,   lambda { |dir| order("contacts.surname #{dir.to_s}, contacts.name #{dir.to_s}, human_resources.name #{dir.to_s}") }
  scope :sort_resource_by_type,      lambda { |dir| order("le_resource_types.name #{dir.to_s}, human_resources.name #{dir.to_s}") }
  scope :sort_resource_by_currency,  lambda { |dir| order("le_currencies.name #{dir.to_s}, human_resources.name #{dir.to_s}") }


  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------

  # Computes a shorter description for the name associated with this data
  def get_full_name
    [
      (name.empty? ? nil : name),
      (self.contact.nil? ? "" : "(#{self.contact.get_full_name })")
    ].compact.join(", ")
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    [
      (name.empty? ? nil : name),
      (self.contact.nil? ? "" : "(#{self.contact.get_verbose_name })"),
      get_verbose_costs
    ].compact.join(", ")
  end

  # Computes a verbose list for the costs associated with this data
  def get_verbose_costs
    currency_symbol = get_currency_symbol()
    "Std: #{cost_std_hour} / Ext: #{cost_ext_hour} / Km: #{cost_km} (#{currency_symbol})"
  end
  # ----------------------------------------------------------------------------

  # Retrieves the default currency checking also for a default value inside app_parameters.
  # Self value of le_currency_id acts as an override, otherwise AppParameter.get_default_currency_id will be used.
  #
  def get_default_currency_id
    self.le_currency_id ? self.le_currency_id : AppParameter.get_default_currency_id()
  end

  # Retrieves associated currency symbol
  def get_currency_symbol
    self.le_currency.nil? ? "" : self.le_currency.display_symbol
  end

  # Retrieves associated currency name
  def get_currency_name
    self.le_currency.nil? ? "" : self.le_currency.name
  end
  # ----------------------------------------------------------------------------
end
