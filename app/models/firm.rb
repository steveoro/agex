require 'common/format'


class Firm < ActiveRecord::Base

  belongs_to :le_city
  belongs_to :le_currency
  belongs_to :le_invoice_payment_type

  has_many :contacts
  has_many :le_users

  before_destroy :validate_erase


  validates_associated :le_city
  validates_associated :le_currency
  validates_associated :le_invoice_payment_type

  validates_presence_of :name
  validates_length_of :name, :within => 1..80
  validates_uniqueness_of :name, :scope => [ :le_city_id, :address, :tax_code, :vat_registration ],
                      :message => :already_exists

  validates_length_of :address, :maximum => 255, :allow_nil => true

  validates_length_of :tax_code, :maximum => 18, :allow_nil => true
  validates_length_of :vat_registration, :maximum => 20, :allow_nil => true

  validates_length_of :phone_main, :maximum => 40, :allow_nil => true
  validates_length_of :phone_hq, :maximum => 40, :allow_nil => true
  validates_length_of :phone_fax, :maximum => 40, :allow_nil => true
  validates_length_of :e_mail, :maximum => 100, :allow_nil => true

  validates_length_of :bank_name, :maximum => 80, :allow_nil => true
  validates_length_of :bank_cc, :maximum => 40, :allow_nil => true
  validates_length_of :bank_abicab, :maximum => 80, :allow_nil => true

  validates_length_of :logo_image_big, :maximum => 255, :allow_nil => true
  validates_length_of :logo_image_short, :maximum => 255, :allow_nil => true


  scope :still_available, where(:is_out_of_business => false)
  scope :house_firms, where(:is_user => true)
  scope :committers,  where(:is_committer => true)
  scope :partners,    where(:is_partner => true)
  scope :vendors,     where(:is_vendor => true)
  scope :team_owners, where( "is_user = :is_user OR is_partner = :is_partner", {:is_user => true, :is_partner => true} )


  scope :sort_firm_by_verbose_name,     lambda { |dir| order("firms.name #{dir.to_s}, firms.address #{dir.to_s}") }

  #--
  # Note: boolean validation via a typical...
  #
  #   validates_format_of :is_user_before_type_cast, :with => /[01]/, :message=> :must_be_0_or_1
  #
  # ...must *not* be used since the ExtJS grids convert internally the values from string/JSON text.


  # ---------------------------------------------------------------------------
  # Base methods:
  # ---------------------------------------------------------------------------


  # Computes a shorter description for the name associated with this data
  def get_full_name
    self.name.to_s
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    ( self.le_city.nil? ? "#{self.name}" : "#{self.name} (#{self.le_city.get_full_name })" )
  end

  # Retrieves an array of title string names that can be used for both
  # report titles (and subtitles) or as base names of any output file created
  # with the data associated with this row instance.
  #
  # The array contains any header description characterizing this row instances,
  # in the form:
  #     [ header_description_1, header_description_2, ... ]
  #
  # I can be easily rendered with [].join(" - ") for being drawn on a single line.
  # The purpose of this method is obviously to obtain a verbose unique 'title'
  # identifier which best describes the whole dataset this row belongs to.
  #
  def get_title_names
    [ get_verbose_name ]
  end
  # ---------------------------------------------------------------------------


  # Computes a shorter description for the address associated with this data
  def get_full_address
    [
      (address.empty? ? nil : address),
      (self.le_city.nil? ? nil : self.le_city.get_full_name)
    ].compact.join(", ")
  end

  # Computes a verbose or formal description for the address associated with this data
  def get_verbose_address
    [
      (address.empty? ? nil : address),
      (self.le_city.nil? ? nil : self.le_city.get_verbose_name)
    ].compact.join(", ")
  end
  # ---------------------------------------------------------------------------
  #++

  # Retrieves the default currency checking also for a default value inside app_parameters.
  # Self value of le_currency_id acts as an override, otherwise AppParameter.get_default_currency_id will be used.
  #
  def get_default_currency_id
    self.le_currency_id ? self.le_currency_id : AppParameter.get_default_currency_id()
  end
  # ---------------------------------------------------------------------------
  #++

  # Retrieves a firm name by its id. In case the find is unsuccessful, returns "".
  def Firm.get_name_by_id( id )
    if id && id.to_i > 0 && ( result = Firm.find(:first, :conditions => "id=#{id}") ) # avoid raising an exception, simply returning null if not found
      result.get_full_name
    else
      ''
    end
  end

  # Retrieves a subset of class ids given the likeliness of a full descriptive naming column.
  # (In the case of a person, that is surname + name.)
  def Firm.get_ids_by_name( full_name )
    ids_found = []
    begin
      if full_name
        rows_found = Firm.find_by_sql( ["SELECT * FROM firms WHERE " +
                                        "(name like ?)" +
                                        " ORDER BY name ASC",
                                        full_name] )
      else
        rows_found = Firm.find( :all )
      end
      rows_found.each { |c| (ids_found << c.id) }
    rescue
      $stderr.print "*[E]* Firm.get_ids_by_name(#{full_name}) failed:\r\n " + $!
    end
    return ids_found
  end
  # ---------------------------------------------------------------------------
  #--


  # ---------------------------------------------------------------------------
  # Entity interface implementation:
  # ---------------------------------------------------------------------------
  #++


  # Checks and sets unset fields to default values.
  #
  # === Parameters:
  # - +params_hash+ => Hash of additional parameter values for attribute defaults override.
  #
  def preset_default_values( params_hash = {} )
    self.le_currency_id = self.get_default_currency_id() if self.le_currency.nil? || self.le_currency_id.to_i < 1
    self
  end


  # ---------------------------------------------------------------------------
  # Data-Export (& conversion) Interface implementation:
  # ---------------------------------------------------------------------------
  #++


  # Returns a (constant) Array of symbols used as key reference for header fields or column titles.
  # This header can then be used for both printable (PDF, TXT, ODT) and data (OUT, XML, whatever) export
  # file formats.
  #
  # Note that these do not necessarily correspond to actual column names, but they will be nevertheless
  # used as key indexes to process each row of the final data hash sent to the either the layout builders
  # or the data export methods. The contract to assure field existance is delegated to the implementors
  # or the utilizing methods.
  #
  def self.header_symbols()
    [
      :name, :address, :le_city, :tax_code, :vat_registration,
      :phone_main, :phone_hq, :phone_fax, :e_mail,
      :is_user, :is_committer, :is_partner, :is_vendor,
      :notes,
      :bank_name, :bank_cc, :bank_abicab, :le_currency, :bank_notes,
      :is_out_of_business,
      :le_invoice_payment_type
    ]
  end
  # ---------------------------------------------------------------------------


  protected


  def validate_erase
    error_msg = nil
    result = true

    if self.is_user?
      error_msg = I18n.t("Cannot delete a firm marked as a 'user'!")
      result = false
    end
    if (self.id == AppParameter.get_default_firm_id())
      error_msg = I18n.t("Cannot delete the default firm!")
      result = false
    end

    unless error_msg.nil?
      logger.warn("\n\r[*W*] Attempt to erase a required firm blocked. Error msg: " + error_msg)
      errors.add_to_base(error_msg)
      throw(error_msg)
    end
    return result
  end
  # ----------------------------------------------------------------------------
end
