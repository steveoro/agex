require 'common/format'


class Contact < ActiveRecord::Base

  belongs_to :le_title
  belongs_to :le_city
  belongs_to :le_contact_type
  belongs_to :firm

  validates_associated :le_title
  validates_associated :le_city
  validates_associated :le_contact_type
  validates_associated :firm

  validates_presence_of :name
  validates_length_of :name, :within => 1..40
  validates_length_of :surname, :maximum => 80
  validates_length_of :address, :maximum => 255, :allow_nil => true

  validates_uniqueness_of :name, :scope => [ :surname, :le_city_id, :address ],
                      :message => :already_exists

  validates_length_of :tax_code, :maximum => 18, :allow_nil => true
  validates_length_of :vat_registration, :maximum => 20, :allow_nil => true

  validates_length_of :phone_home, :maximum => 40, :allow_nil => true
  validates_length_of :phone_work, :maximum => 40, :allow_nil => true
  validates_length_of :phone_cell, :maximum => 40, :allow_nil => true
  validates_length_of :phone_fax, :maximum => 40, :allow_nil => true
  validates_length_of :e_mail, :maximum => 100, :allow_nil => true
  #--
  # Note: boolean validation via a typical...
  #
  #   validates_format_of :is_suspended_before_type_cast, :with => /[01]/, :message=> :must_be_0_or_1
  #
  # ...must *not* be used since the ExtJS grids convert internally the values from string/JSON text.

  # [Steve, 20120212] Using "netzke_attribute" helper to define in the model the configuration
  # of each column/attribute makes localization of the label unusable, since the model class is
  # receives the "netzke_attribute" configuration way before the current locale is actually defined.
  # So, it is way better to keep column configuration directly inside Netzke components or in the
  # view definition using the netzke helper.


  scope :sort_contact_by_title, lambda { |dir| order("le_titles.name #{dir.to_s}, contacts.surname #{dir.to_s}, contacts.name #{dir.to_s}") }
  scope :sort_contact_by_type,  lambda { |dir| order("le_contact_types.name #{dir.to_s}, contacts.surname #{dir.to_s}, contacts.name #{dir.to_s}") }
  scope :sort_contact_by_city,  lambda { |dir| order("le_cities.name #{dir.to_s}, contacts.surname #{dir.to_s}, contacts.name #{dir.to_s}") }
  scope :sort_contact_by_firm,  lambda { |dir| order("firms.name #{dir.to_s}, contacts.surname #{dir.to_s}, contacts.name #{dir.to_s}") }


  # ---------------------------------------------------------------------------
  # Base methods:
  # ---------------------------------------------------------------------------
  #++


  # Computes a shorter description for the name associated with this data
  def get_full_name
    [
      (surname.empty? ? nil : surname),
      (name.empty? ? nil : name)
    ].compact.join(" ")
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    [
      (self.le_title.nil? ? nil : self.le_title.name),
      get_full_name
    ].compact.join(" ")
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
    [ self.get_verbose_name, (self.firm ? self.firm.get_full_name : '') ]
  end
  # ---------------------------------------------------------------------------
  #++


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
  #-----------------------------------------------------------------------------
  #++

  # Retrieves a subset of class ids given the likeliness of a full descriptive naming column.
  # (In the case of a person, that is surname + name.)
  def Contact.get_ids_by_name( full_name )
    ids_found = []
    begin
      if full_name
        rows_found = Contact.find_by_sql( ["SELECT * FROM contacts WHERE " +
                                           "(concat(surname,\" \",name) like ?)" +
                                           " ORDER BY surname ASC",
                                           full_name] )
      else
        rows_found = Contact.find( :all )
      end
      rows_found.each { |c| (ids_found << c.id) }
    rescue
      $stderr.print "*[E]* Contact.get_ids_by_name(#{full_name}) failed:\r\n " + $!
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
    unless self.firm
      begin
        default_firm_id = params_hash[:firm_id] ||
                          ( params_hash[:user_id] && LeUser.find(params_hash[:user_id].to_i).firm_id )
        self.firm_id = default_firm_id
      rescue
        self.firm_id = nil
      end
    end
                                                    # Set default date for this entry:
    self.date_last_met = Time.now unless self.date_last_met
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
      :name, :surname, :address, :le_city,
      :tax_code, :vat_registration, :date_birth,
      :phone_home, :phone_work, :phone_cell, :phone_fax, :e_mail,
      :firm, :is_suspended
    ]
  end
  # ---------------------------------------------------------------------------
end
