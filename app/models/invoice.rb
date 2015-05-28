# encoding: utf-8

require 'ruport'
require 'common/format'


=begin

= Invoice model

  - AgeX framework vers.:  3.06.00
  - author: Steve A.

=end
class Invoice < ActiveRecord::Base

  has_many :invoice_rows

  belongs_to :firm
  belongs_to :le_currency
  belongs_to :le_invoice_payment_type

  belongs_to :recipient_firm, :class_name  => "Firm",
                              :foreign_key => "recipient_firm_id"
                              # Note that if we get too specific with conditions here, ActiveRecords nils out the associations
                              # rows that do not respond to the constraints, as in the case of having a non-vendor id nulled specifing
                              # for example :conditions => "((firms.is_committer = 1) or (firms.is_vendor = 1))".
                              # To filter out rows see the ActiveScaffold association conditions override in the Helper file.
  validates_presence_of :firm_id
  validates_associated  :firm

  validates_presence_of :recipient_firm_id
  validates_associated  :recipient_firm

  validates_associated  :le_currency
  validates_associated  :le_invoice_payment_type


  validates_presence_of :name
  validates_length_of :name, :within => 1..40
  validates_length_of :description, :maximum => 80, :allow_nil => true
  validates_presence_of :header_object
  validates_length_of :header_object, :within => 1..255

  validates_presence_of :invoice_number
  validates :invoice_number, :numericality => {:greater_than => 0}

  validates :social_security_cost, :numericality => {:greater_than => -1.0, :less_than => 1.0}
  validates :vat_tax, :numericality => {:greater_than => -1.0, :less_than => 1.0}
  validates :account_wage, :numericality => {:greater_than => -1.0, :less_than => 1.0}
  validates_numericality_of :total_expenses

  #--
  # Note: boolean validation via a typical...
  #
  #   validates_format_of :is_fully_payed_before_typecast, :with => /[01]/, :message=> :must_be_0_or_1
  #
  # ...must *not* be used since the ExtJS grids convert internally the values from string/JSON text.


  scope :still_due, where(:is_fully_payed => false)

  scope :sort_invoice_by_currency,      lambda { |dir| order("le_currencies.display_symbol #{dir.to_s}, invoices.name #{dir.to_s}") }
  scope :sort_invoice_by_firm,          lambda { |dir| order("firms.name #{dir.to_s}, invoices.name #{dir.to_s}") }
  scope :sort_project_by_recipient,     lambda { |dir| order("recipient_firms_invoices.name #{dir.to_s}, invoices.name #{dir.to_s}") }
  scope :sort_invoice_by_payment_type,  lambda { |dir| order("le_invoice_payment_types.name #{dir.to_s}, invoices.name #{dir.to_s}") }


  # Default invoice type, with VAT, standard fiscal regime
  TYPE_DEFAULT_ID = 0

  # Default invoice type, with VAT, "minimum" fiscal regime
  TYPE_MINIUM_ID = 1


  # ---------------------------------------------------------------------------
  # Base methods:
  # ---------------------------------------------------------------------------


  # Computes a shorter description for the name associated with this data
  def get_full_name
    (name.nil? || name.empty?) ? get_number_with_year : "#{get_number_with_year} (#{name})"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    (description.nil? || description.empty?) ? get_full_name : "#{get_full_name}: #{description}"
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
    [ get_year_with_number(), self.recipient_firm.name.split(' ')[0] ]
  end

  # Uses +get_title_names+() to obtain a single string name usable as
  # base file name for many output reports or data exchange files created while removing
  # special chars that may conflict with legacy filesystems.
  #
  def get_base_name
    get_title_names().join("_").gsub(/[òàèùçé^!"'£$%&?.,;:§°<>]/,'').gsub(/[\s|]/,'_').gsub(/[\\\/=]/,'-')
  end
  # ---------------------------------------------------------------------------


  # Retrieves associated firm name
  def get_firm_name
    self.firm.nil? ? "" : self.firm.get_full_name
  end

  # Retrieves associated Recipient firm name
  def get_recipient_name
    self.recipient_firm.nil? ? "" : self.recipient_firm.get_full_name
  end

  # Retrieves associated currency symbol
  def get_currency_symbol
    self.le_currency.nil? ? "" : self.le_currency.display_symbol
  end

  # Retrieves associated currency name
  def get_currency_name
    self.le_currency.nil? ? "" : self.le_currency.name
  end

  # Retrieves payment type description
  def get_payment_type
    self.le_invoice_payment_type.nil? ? "" : self.le_invoice_payment_type.name
  end
  # ---------------------------------------------------------------------------


  # Computes a displayable numeric description of the invoice, using its number and the year in four digits.
  # (e.g.: "4/2007")
  def get_number_with_year
    invoice_number.to_s + "/" + date_invoice.strftime("%Y")
  end

  # The opposite of +get_year_with_number+, but prefixing also the number with leading zeroes.
  # Perfectly suitable for filenames (e.g.: "2007-0004")
  def get_year_with_number
    date_invoice.strftime("%Y") + "-" + sprintf( "%04i", invoice_number )
  end

  # Retrieves the next invoice number, as integer.
  #
  def get_next_invoice_number( curr_year = Time.now.year )
    if (self.firm_id == nil) || (self.firm_id < 1)
      raise ArgumentError, "Invoice.get_next_invoice_number(): Invalid current firm id!", caller
    end
    rows_found = Invoice.find_by_sql( ["SELECT max(invoice_number) + 1 AS next_value, firm_id FROM invoices" +
                                       " WHERE (year(date_invoice) = ?) and (firm_id = ?) GROUP BY firm_id",
                                       curr_year, self.firm_id] )
    rows_found.length > 0 ? rows_found[0].next_value.to_i : 1
  end
  # ---------------------------------------------------------------------------


  # Virtual field getter: formats the value as text.
  def formatted_vat_tax()
    Format.float_to_percent( self.vat_tax )
  end

  # Virtual field getter: formats the value as text.
  def formatted_account_wage()
    Format.float_to_percent( self.account_wage )
  end

  # Virtual field getter: formats the value as text.
  def formatted_social_security_cost()
    Format.float_to_percent( self.social_security_cost )
  end

  # Virtual field getter: formats the value as text.
  def formatted_total_expenses()
    self.total_expenses.to_s + ' ' + get_currency_symbol()
  end
  # ---------------------------------------------------------------------------


  # Retrieves the default currency from this invoice's firm_id, if set, or else it
  # searches for a default value (or its override) inside app_parameters.
  #
  def get_default_currency_id
    self.firm ? self.firm.get_default_currency_id() : AppParameter.get_default_currency_id()
  end
  # ---------------------------------------------------------------------------


  # Checks and sets unset fields to default values.
  #
  # === Parameters:
  # - +params_hash+ => Hash of additional parameter values for attribute defaults override.
  #
  def preset_default_values( params_hash = {} )
    unless self.firm || params_hash[:firm_id].blank?  # Set attribute only if not set
      self.firm_id = params_hash[:firm_id].to_i
    end
    self.invoice_number = self.get_next_invoice_number() unless self.invoice_number && self.invoice_number != ""
    self.date_invoice = Time.now unless self.date_invoice
                                                    # Compute a default naming alias:
    width = 4                   # (if invoice number will have more than "width" digits, no zeroes will be prepended)
    self.name = sprintf( "%4i-%0#{width}i-", self.date_invoice.year, self.invoice_number ) +
                self.firm.name.split(' ')[0] if self.firm && (self.name.nil? || self.name == "")
    self.name[0..39] if self.name.length > 40

    if self.social_security_cost == 0 or self.account_wage == 0 or self.vat_tax == 0
      ap = AppParameter.get_parameter_row_for( :invoices )
      if ap
        self.social_security_cost = ap.send( NamingTools.get_field_name_for_default_value_in_app_parameters_for(:invoices, :soc_security) ) unless self.social_security_cost != 0
        self.account_wage         = ap.send( NamingTools.get_field_name_for_default_value_in_app_parameters_for(:invoices, :account_wage) ) unless self.account_wage != 0
        self.vat_tax              = ap.send( NamingTools.get_field_name_for_default_value_in_app_parameters_for(:invoices, :vat_tax) ) unless self.vat_tax != 0
      end
    end
                                                    # Set default currency:
    self.le_currency_id = self.get_default_currency_id() if self.le_currency.nil? || self.le_currency_id.to_i < 1
    self.le_invoice_payment_type_id = self.firm.le_invoice_payment_type_id if self.firm
    self
  end


  # ---------------------------------------------------------------------------
  # List Summary & Reporting:
  # ---------------------------------------------------------------------------



  # Returns a list of +Hash+ keys of any additional text label to be localized, different from any
  # other existing record field or getter method already included in +report_header_symbols+ or
  # +report_detail_symbols+ (since these are just referring to data fields and not to any other
  # additional text that may be used in the report layout).
  #
  def self.report_label_symbols()
    [
      :customer,
      :phone_main,
      :phone_fax,
      :e_mail,
      :tax_code,
      :vat_registration,
      :notes_title,
      :copy_watermark,
      :banking_coordinates
    ]
  end

  # Returns the list of "header" +Hash+ keys (the +Array+ of +Symbols+) that will be used to create the result
  # of <tt>prepare_report_header_hash()</tt> and that will also be added to the list of all possible (localized)
  # "labels" returned by <tt>self.get_label_hash()</tt>.
  #
  def self.report_header_symbols()
    [
      :report_title,
      :date,
      :company_name,
      :company_full_address,
      :company_phone_main,
      :company_phone_hq,
      :company_phone_fax,
      :company_e_mail,
      :company_tax_code,
      :company_vat_registration,
      :customer_name,
      :customer_full_address,
      :customer_phone_main,
      :customer_phone_hq,
      :customer_phone_fax,
      :customer_e_mail,
      :customer_tax_code,
      :customer_vat_registration,
      :header_object,

      :notes_text,
      :bank_cc,
      :bank_cin_abicab
    ]
  end


  # Prepares and returns the result hash containing the header data fields specified
  # in the <tt>report_header_symbols()</tt> list.
  #
  def prepare_report_header_hash()
    {
      :report_title               => get_year_with_number,
      :date                       => Format.a_date( date_invoice ),
      :company_name               => firm.name,
      :company_full_address       => firm.get_full_address,
      :company_phone_main         => firm.phone_main,
      :company_phone_hq           => firm.phone_hq,
      :company_phone_fax          => firm.phone_fax,
      :company_e_mail             => firm.e_mail,
      :company_tax_code           => firm.tax_code,
      :company_vat_registration   => firm.vat_registration,
      :company_logo_big           => firm.logo_image_big ? "public/images/#{firm.logo_image_big}.jpg" : nil,
      :company_logo_short         => firm.logo_image_short ? "public/images/#{firm.logo_image_short}.jpg" : nil,
      :customer_name              => recipient_firm.name,
      :customer_full_address      => recipient_firm.get_full_address,
      :customer_phone_main        => recipient_firm.phone_main,
      :customer_phone_hq          => recipient_firm.phone_hq,
      :customer_phone_fax         => recipient_firm.phone_fax,
      :customer_e_mail            => recipient_firm.e_mail,
      :customer_tax_code          => recipient_firm.tax_code,
      :customer_vat_registration  => recipient_firm.vat_registration,
      :header_object              => header_object,

      :notes_text                 => [ get_payment_type, notes.to_s],
      :bank_name                  => firm.bank_name,
      :bank_cc                    => firm.bank_cc ? sprintf( "%012.0f", firm.bank_cc ) : "",
      :bank_cin_abicab            => firm.bank_abicab
    }
  end


  # Builds up an Hash that can be used to create a summary table containing the columns [ :report_title, :firm, :recipient_firm ]
  # for each one of the row instances specified with the parameters.
  #
  # This hash can then be sent to prepare_summary_table() to obtain the actual summary table to be displayed.
  #
  # === Parameters:
  # - +:records+ => an Array of record rows to be processed
  #
  def self.prepare_summary_hash( params_hash = {} )
    unless  records.kind_of?(ActiveRecord::Relation) || records.kind_of?(Array)
      raise ArgumentError, "Invoice.prepare_summary_hash(): invalid records parameter!", caller
    end
    return {} if params_hash[:records].size == 0    # (Bail out if there's nothing to do)
    summary_rows  = []
    currency_name = nil
    records       = params_hash[:records]
                                                    # Loop on records, gather data for each summary row:
    records.each { |invoice|
      summary_hash = InvoiceRow.prepare_summary_hash( :parent_id => invoice.id )
      summary_rows << [
        invoice.get_year_with_number,
        invoice.firm.name,
        invoice.recipient_firm.name,
        summary_hash[:grand_total]                  # (Element #3 must be formatted only after usage, below)
      ]                                             # Store currency name as soon as you have it:
      currency_name = summary_hash[:currency_name] if currency_name.nil?
    }                                               # Finally, create and add a grand total summary row at the end:
    grand_total = summary_rows.collect {|row| row[3]}.inject {|sum, v| sum + v}
    summary_rows << [
      "#{I18n.t(:grouping_total_label, {:scope=>[:invoice_row]} ).upcase}:",
      nil, nil, grand_total
    ]

    return {
      :column_names => ( [ :report_title, :firm, :recipient_firm ].collect! { |s| I18n.t(s.to_sym, {:scope=>[:invoice_row]}) } ) << currency_name,
      :data => summary_rows,
      :grand_total => grand_total,
      :currency_name => currency_name
    }
  end
  # ---------------------------------------------------------------------------


  # TODO NOT USED & TESTED YET:::::::::::::::::

  # Prepares the +Ruport::Data::Table+ representing the collected data from +prepare_summary_hash+()
  # in a format easily displayed by the "summary view interface".
  #
  # === Parameters:
  #
  # - +summary_hash+ =>
  #   The same kind of hash as the one resulting from a +prepare_summary_hash+() call.
  #
  # - +use_fixed_width_for_floats+ =>
  #   When true all float values will have a fixed width to be easily aligned in text files.
  #   Defaults to false.
  #
  def self.prepare_summary_table( summary_hash, use_fixed_width_for_floats = false )
    unless summary_hash.instance_of?(Hash) && (summary_hash.keys - [ :report_title, :firm, :recipient_firm ] == [])
      raise ArgumentError, "Invoice.prepare_summary_table(): invalid summary_hash parameter!", caller
    end
                                                    # Apply fixed format if requested:
    formatted_summary_hash = {
      :column_names => summary_hash[:column_names],
      :data => ( summary_hash[:data].nil? ?
          [] :
          summary_hash[:data].each{ |row|
            row[3] = use_fixed_width_for_floats ? Format.float_value( row[3] ) : row[3] # (this is :grand_total from the row Hash computed with the method above)
          }
      )
    }
                                                    # Create and return the table:
    return Ruport::Data::Table.new( formatted_summary_hash )
  end
  # ---------------------------------------------------------------------------


  # TODO NOT USED & TESTED YET:::::::::::::::::

  # Same as +prepare_summary_table+ but without any amount or currency (for privacy reasons).
  # Mainly used by controller +info+.
  # Prepares the +Ruport::Data::Table+ representing the specified data
  # in a format easily displayed by the "summary view interface".
  #
  # [2010 Update] This method is actually used only by the Info controllers (for privacy reasons).
  #
  # === Parameters:
  #
  # - +records+ =>
  #   The Array of record rows to be processed (same instance as this model).
  #
  def self.prepare_summary_table_without_amounts( records )
    if (records == nil) || (! records.instance_of?(Array))
      raise ArgumentError, "Invoice.prepare_summary_table_without_amounts(): invalid records list!", caller
    end
    return {} if records.size == 0                 # (Bail out if there's nothing to do)
    summary_rows = []
    records.each { |invoice|                       # Loop on records, gather data for each summary row:
      summary_rows << [
        invoice.get_year_with_number,
        invoice.firm.name,
        invoice.recipient_firm.name
      ]
    }
    summary_table_hash = {
      :column_names => [ :report_title, :firm, :recipient_firm ].collect! { |s| I18n.t(s.to_sym, {:scope=>[:invoice_row]}) },
      :data => summary_rows
    }

    return Ruport::Data::Table.new( summary_table_hash )
  end
  # ---------------------------------------------------------------------------
end
