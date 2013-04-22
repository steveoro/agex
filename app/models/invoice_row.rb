# encoding: utf-8

require 'ruport'
require 'common/format'
require 'framework/interface_data_export'


class InvoiceRow < ActiveRecord::Base

  include InterfaceDataExport

  belongs_to :invoice
  belongs_to :project
  belongs_to :le_invoice_row_unit
  belongs_to :le_currency

  validates_presence_of :invoice_id
  validates_associated :invoice

  validates_associated :project
  validates_associated :le_invoice_row_unit
  validates_associated :le_currency

  validates_numericality_of :quantity
  validates_numericality_of :unit_cost
  validates_numericality_of :vat_tax
  validates_numericality_of :discount

  validates_presence_of :description
  validates_length_of :description, :within => 1..255

  scope :sort_invoice_row_by_project,   lambda { |dir| order("projects.name #{dir.to_s}") }
  scope :sort_invoice_row_by_unit,      lambda { |dir| order("le_invoice_row_units.name #{dir.to_s}") }
  scope :sort_invoice_row_by_currency,  lambda { |dir| order("le_currencies.display_symbol #{dir.to_s}") }


  # ---------------------------------------------------------------------------
  # Base methods:
  # ---------------------------------------------------------------------------


  # Returns the parent entity id value, if there is one. Usually inside the framework,
  # for ProjectRow is project_id, for InvoiceRow is invoice_id, for TeamRow is team_id
  # and so on.
  def get_parent_id()
    self.invoice_id
  end

  # Returns a shorter description for the name associated with this data
  def get_full_name
    (description.nil? || description.empty?) ? "" : description
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
    self.invoice.get_title_names()
  end
  # ---------------------------------------------------------------------------
  #++

  # Calc field: quantity converted to an integer if it has no decimals
  def round_quantity
    (self.quantity - self.quantity.truncate).zero? ? self.quantity.to_i : self.quantity
  end

  # Calc field: full taxable amount for this row of invoice
  def taxable_amount
    self.quantity.to_f * self.unit_cost.to_f
  end

  # Calc field: net amount for this row of invoice
  def net_amount
    taxable_amount() - (taxable_amount() * self.discount.to_f)
  end

  # Calc field: net tax amount for this row of invoice (without any social security amount added)
  def net_tax
    net_amount() * self.vat_tax.to_f
  end

  # Calc field: VAT percentage
  def vat_tax_percent
    self.vat_tax.to_f * 100
  end

  # Calc field: discount percentage
  def discount_percent
    self.discount.to_f * 100
  end


  # Returns row cost, assuming both vat_tax and discount are decimal percentiles (range: 0.0 .. 1.0)
  def get_row_cost
    net_amount() +
    (net_amount() * self.invoice.social_security_cost.to_f) +
    (net_amount() + (net_amount() * self.invoice.social_security_cost.to_f)) * self.vat_tax.to_f
  end

  # Retrieves associated currency symbol
  def get_currency_symbol
    self.le_currency.nil? ? "" : self.le_currency.display_symbol
  end

  # Retrieves associated currency symbol
  def get_project_name
    self.project.nil? ? "" : self.project.get_full_name
  end

  # Retrieves row unit description
  def get_row_unit_name
    self.le_invoice_row_unit.nil? ? "" : (self.le_invoice_row_unit.name.length < 7 ? self.le_invoice_row_unit.name : self.le_invoice_row_unit.name[0..3] +'.')
  end
  # ---------------------------------------------------------------------------


  # Retrieves the default currency from the parent row if set.
  # Else, it searches for a default value using its parent get_default_currency() method.
  # In any case, the parent link column attribute must be present in current instance.
  #
  def get_default_currency_id
    raise "Invoice id not set for this row!" unless self.invoice

    if self.invoice.le_currency_id                  # Get default currency from parent invoice:
      self.invoice.le_currency_id
    else                                            # Get default currency using parent method:
      self.invoice.get_default_currency_id()
    end
  end
  # ---------------------------------------------------------------------------

# FIXME ***********************************+ vvvvvvvv TEST this one below:

  # Checks and sets unset fields to default values.
  #
  # === Parameters:
  # - +params_hash+ => Hash of additional parameter values for attribute defaults override.
  #
  def preset_default_values( params_hash = {} )
    unless self.invoice || params_hash[:invoice_id].blank?
      self.invoice_id = params_hash[:invoice_id].to_i
    end
    self.quantity = 1.0 if self.quantity == 0
    self.unit_cost = 10.0 if self.unit_cost == 0
    ap = AppParameter.get_parameter_row_for( :invoices )
    if ap
      self.vat_tax  = ap.send( NamingTools.get_field_name_for_default_value_in_app_parameters_for(:invoices, :vat_tax) ) unless self.vat_tax != 0
      self.discount = ap.send( NamingTools.get_field_name_for_default_value_in_app_parameters_for(:invoices, :discount) ) unless self.discount != 0
    end
                                                    # Set default currency:
    self.le_currency_id = self.get_default_currency_id() if self.le_currency.nil? || self.le_currency_id.to_i < 1
    self
  end
  # ---------------------------------------------------------------------------
  #--


  # ---------------------------------------------------------------------------
  # List Summary & Reporting:
  # ---------------------------------------------------------------------------
  #++


  # (Constant) precision of Floats converted to String values
  #
  CONVERTED_FLOAT2STRING_FIXED_PRECISION = 2

  # (Constant) Blank filler length of Floats converted to String values
  #
  CONVERTED_FLOAT2STRING_FIXED_LENGTH    = 15

  # (Constant) Blank filler length of Floats converted to String percentages (including ' %')
  #
  CONVERTED_PERCENT2STRING_FIXED_LENGTH  = 6


  # Returns the text label to be used as a description for the result of groupings between
  # row instances of this entity.
  #
  # def self.grouping_label()
    # 'Grand total'
  # end
  # ---------------------------------------------------------------------------

  # List of Column symbols or Label symbols that will receive the currency name in between brackets when
  # the text localization will be applied.
  #
  CURRENCY_SYMS = [
      :unit_cost,
      :taxable_amount,
      :net_tax,
      :net_amount
  ]

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
      :round_quantity,
      :le_invoice_row_unit,
      :description,
      :unit_cost,
      :taxable_amount,            # calc field
      :discount,
      :vat_tax,
      :net_tax,                   # calc field
      :net_amount                 # calc field
    ]
  end

  # Returns a (constant) Array of symbols used to define the (default) output sequence 
  # for methods like +to_csv+ or +to_a_s+.
  # Note that is still possible to specify custom symbols arrays as parameters for +to_csv+ or +to_a_s+,
  # to obtain export field sets other than the default set.
  #
  # Association columns should use here the name of the association instead of the key of
  # column (or the column name), so that if the association model implements the +to_label+ method,
  # this will be used to render its value to text (as it's the default case for any EntityBase
  # sibling).
  #
  def self.data_symbols()
    [
      :round_quantity,
      :le_invoice_row_unit,
      :description,
      :unit_cost,
      :taxable_amount,            # calc field
      :discount_percent,          # calc field
      :vat_tax_percent,           # calc field
      :net_tax,                   # calc field
      :net_amount                 # calc field
    ]
  end

  # Returns the list of the "detail" key +Symbols+ that will be used to create the result
  # of <tt>prepare_report_detail()</tt> and that will also be added to the list of all possible (localized)
  # "labels" returned by <tt>self.get_label_hash()</tt>.
  #
  # Note that for the "reporting interface" there's still no equivalent to the +header_symbols+
  # of the "data export interface" because the +report_header_symbols+ are actually keys for
  # the report header hash - whenever this is defined.
  # So, in case any of the +report_detail_symbols+ are referring to fields or methods that
  # may need a custom column heading, special cases must be added to self.get_label() in order
  # to obtain the desired label anyway.
  #
  def self.report_detail_symbols()
    data_symbols()
  end


  # Prepares and returns the result data containing the detail fields as specified
  # in the <tt>report_detail_symbols()</tt> list.
  # Returns a Ruport::Data::Table containing the formatted rows of records.
  #
  # === Parameters:
  #
  # - :+records+ =>
  #   an Array of record instances on which the detail data must be collected and prepared.
  #   This must be already filtered and sorted accordingly, since no more sorting will
  #   be performed by this method.
  #
  # - :+rjustification+ => numbers of blank fillers to be used for fixed-width floats;
  #   this is useful actually only for text file formatting, for PDF files ignore this option
  #   (justification is column based and layout-specific). Defaults to 0.
  #
  def self.prepare_report_detail( options_hash = {} )
    records = options_hash[:records]
    unless  records.kind_of?(ActiveRecord::Relation) || records.kind_of?(Array)
      raise ArgumentError, "InvoiceRow.prepare_report_detail(): invalid records parameter!", caller
    end
    precision = CONVERTED_FLOAT2STRING_FIXED_PRECISION
    rjust     = options_hash[:rjustification].to_i
                                                    # Collect and add the raw data:
    array_of_raw_data = records.collect { |row|
      row.to_a_s( report_detail_symbols(), precision, rjust )
    }
                                                    # Build data set as a "reportable" table:
    return Ruport::Data::Table.new( :data => array_of_raw_data, :column_names => report_detail_symbols() )
  end
  # ---------------------------------------------------------------------------


  # Computes an SQL sum among rows grouped by the main constraint for this entity (invoice_id).
  #
  # NOTE: this method must be fed with data belonging to just _1_ invoice at a time; if rows from
  # multiple invoices are given, the summary will be a *cumulative* result. (not an array
  # of results, as it is the case with the same method implemented for account_rows.)
  #
  # Alternative methods could also be used (see also the method below which uses
  # Ruport::Data::Table utility method sigma to perform some computations)
  # to avoid local SQL overhead but, as of this version, this is considered the
  # "reference implementation" for the framework.
  #
  # The method computes, mostly by SQL, the total amount for a specific parent id (that
  # is <tt>invoice_id</tt> of InvoiceRow), returning an hash of results containing:
  #<tt>
  #      :sum_cost_x_qty        => sum(row_cost * quantity),
  #      :subtotal              => sum(net_amount),
  #      :total_tax             => sum(net_tax),
  #      :social_security_cost  => invoice.social_security_cost, (using parent_id)
  #      :account_wage          => invoice.account_wage, (using parent_id)
  #      :total_expenses        => invoice.total_expenses,
  #</tt>
  #
  # plus the following computed (from the above) values:
  #<tt>
  #      :social_security_amount
  #      :total_taxable_amount
  #      :total
  #      :account_wage_amount
  #      :grand_total
  #      :currency_name        => LeCurrency.get_name_by( default_currency )
  #</tt>
  #
  # The default currency is retrieved using <tt>self.get_default_currency_id()</tt>.
  #
  # === Options:
  #
  # - <tt>:records</tt> =>
  #   An ActiveRecord::Relation result to be processed (when both <tt>:parent_id</tt> and
  #   <tt>:records</tt> are provided <tt>:records</tt> has the precedence).
  #
  # - <tt>:parent_id</tt> =>
  #   +id+ of the parent entity row which acts as main constraint for the rows that have to
  #   be processed.
  #
  # - <tt>:do_float_formatting</tt> =>
  #   set this != +nil+ to convert to text and enforce a fixed text format for each float value.
  #
  def self.prepare_summary_hash( params_hash = {} )
    parent_id     = params_hash[:parent_id]
    records       = params_hash[:records]
    do_float_formatting = params_hash[:do_float_formatting] != nil

    if parent_id.nil? && records.nil?
      raise(ArgumentError, "InvoiceRow.prepare_summary_hash(): at least one of the parameters parent_id and records have to be supplied for the method to work.", caller)
    end
    if (! records.nil?) && (! records.kind_of?(ActiveRecord::Relation))
      raise ArgumentError, "InvoiceRow.prepare_summary_hash(): invalid records parameter!", caller
    end
    if (! parent_id.nil?) && (parent_id.to_i < 1)
      raise ArgumentError, "InvoiceRow.prepare_summary_hash(): invalid parent_id parameter!", caller
    end
                                                    # The header row must be retrieved anyway to get the parameters for the invoice:
    i = Invoice.find( records ? records[0].invoice_id : parent_id )
    unless i                                        # (This should never happen, since ActiveRecord throws an exception first:)
      raise ArgumentError, "InvoiceRow.prepare_summary_hash(): Invoice id not found!", caller
    end
    social_security_cost = i.social_security_cost
    account_wage         = i.account_wage
    total_expenses       = i.total_expenses
    default_currency     = i.le_currency ? i.le_currency_id : i.get_default_currency_id()

    if records                                      # Issuing an ActiveRelation filtering find is faster than a query:
      subtotals = records.find(
          :all,
          :select => "sum(unit_cost * quantity) as sum_cost_x_qty," +
                     "sum(unit_cost * quantity) - (sum(unit_cost * quantity) * discount) as sum_net_amount," +
                     "( (sum(unit_cost * quantity) - (sum(unit_cost * quantity) * discount)) +" +
                     "  (sum(unit_cost * quantity) - (sum(unit_cost * quantity) * discount)) * #{social_security_cost} ) * vat_tax as sum_net_tax," +
                     "le_currency_id, invoice_id",
          :group => 'invoice_id, le_currency_id'
      )
    else
      subtotals = self.find_rows_with_subtotals( parent_id, social_security_cost )
    end

    sum_cost_x_qty = 0 
    sum_net_amount = 0 
    sum_net_tax    = 0
                                                    # Get the default currency or its override and initialize sums: (this should never change among rows of a same invoice)
    default_currency  = ( subtotals.size == 0 ? 
                          AppParameter.get_default_currency_id() :
                          subtotals[0].get_default_currency_id()
    ) unless default_currency > 0

    subtotals.each { |row|
      sum_cost_x_qty += LeCurrencyExchange.exchange_value( row.sum_cost_x_qty.to_f, row.le_currency_id, default_currency )
      sum_net_amount += LeCurrencyExchange.exchange_value( row.sum_net_amount.to_f, row.le_currency_id, default_currency )
      sum_net_tax    += LeCurrencyExchange.exchange_value( row.sum_net_tax.to_f, row.le_currency_id, default_currency )
    }
    social_security_amount = sum_net_amount * social_security_cost
    total_taxable_amount = sum_net_amount + social_security_amount
    total                = total_taxable_amount + sum_net_tax
    account_wage_amount  = total_taxable_amount * account_wage
    grand_total          = total + account_wage_amount + total_expenses

    return {
      :sum_cost_x_qty         => do_float_formatting ? Format.float_value( sum_cost_x_qty, CONVERTED_FLOAT2STRING_FIXED_PRECISION, CONVERTED_FLOAT2STRING_FIXED_LENGTH ) : sum_cost_x_qty.to_f,
      :subtotal               => do_float_formatting ? Format.float_value( sum_net_amount, CONVERTED_FLOAT2STRING_FIXED_PRECISION, CONVERTED_FLOAT2STRING_FIXED_LENGTH ) : sum_net_amount.to_f,
      :social_security_cost   => Format.float_to_percent( social_security_cost, 0, CONVERTED_PERCENT2STRING_FIXED_LENGTH ),
      :social_security_amount => do_float_formatting ? Format.float_value( social_security_amount, CONVERTED_FLOAT2STRING_FIXED_PRECISION, CONVERTED_FLOAT2STRING_FIXED_LENGTH ) : social_security_amount.to_f,
      :total_taxable_amount   => do_float_formatting ? Format.float_value( total_taxable_amount, CONVERTED_FLOAT2STRING_FIXED_PRECISION, CONVERTED_FLOAT2STRING_FIXED_LENGTH ) : total_taxable_amount.to_f,
      :total_tax              => do_float_formatting ? Format.float_value( sum_net_tax, CONVERTED_FLOAT2STRING_FIXED_PRECISION, CONVERTED_FLOAT2STRING_FIXED_LENGTH ) : sum_net_tax.to_f,
      :total                  => do_float_formatting ? Format.float_value( total, CONVERTED_FLOAT2STRING_FIXED_PRECISION, CONVERTED_FLOAT2STRING_FIXED_LENGTH ) : total.to_f,
      :account_wage           => Format.float_to_percent( account_wage, 0, CONVERTED_PERCENT2STRING_FIXED_LENGTH ),
      :account_wage_amount    => do_float_formatting ? Format.float_value( account_wage_amount, CONVERTED_FLOAT2STRING_FIXED_PRECISION, CONVERTED_FLOAT2STRING_FIXED_LENGTH ) : total_expenses.to_f,
      :total_expenses         => do_float_formatting ? Format.float_value( total_expenses, CONVERTED_FLOAT2STRING_FIXED_PRECISION, CONVERTED_FLOAT2STRING_FIXED_LENGTH ) : total_expenses.to_f,
      :grand_total            => do_float_formatting ? Format.float_value( grand_total, CONVERTED_FLOAT2STRING_FIXED_PRECISION, CONVERTED_FLOAT2STRING_FIXED_LENGTH ) : grand_total.to_f,
      :currency_name          => LeCurrency.get_name_by( default_currency )
    }
  end
  # ----------------------------------------------------------------------------


  # FIXME ************************************vvvvvvvvvvvvv
  # NOT USED ANYMORE:

  # Implements the standard way for computing a "summary" hash for this entity.
  #
  # The method computes the total amount for a specific parent id (+invoice_id+ of InvoiceRow),
  # returning an hash of result values with the format:
  #
  #      :sum_cost_x_qty        => sum(row_cost * quantity),
  #      :subtotal              => sum(net_amount),
  #      :total_tax             => sum( (net_amount + row's social security amout) * vat_tax),
  #      :social_security_cost  => invoice.social_security_cost, (using parent_id)
  #      :account_wage          => invoice.account_wage, (using parent_id)
  #      :total_expenses        => invoice.total_expenses,
  #
  # plus these other computed values, derived from the above:
  #
  #      :social_security_amount
  #      :total_taxable_amount
  #      :total
  #      :account_wage_amount
  #      :grand_total
  #
  #      :currency_name        => LeCurrency.get_name_by( default_currency )
  #
  # The default currency (used to exchange all row currency into a single one) comes from
  # the currently selected user firm, if available.
  #
  # === Parameters:
  # - +parent_id+ => id of the parent entity row which acts as main constraint for the rows that have to be processed
  #
  # - +data_table+ =>
  #   a Ruport::Data::Table containing <tt>data_symbols()</tt> as columns names;
  #   each monetary data must be already converted under a common currency.
  # - +social_security_cost+ => value taken from Invoice.social_security_cost.
  # - +account_wage+ => value taken from Invoice.account_wage.
  # - +total_expenses+ => value taken from Invoice.total_expenses.
  # - +currency_name+ => value taken from Invoice.get_currency_name (returned here for reference).
  # - +do_float_formatting+ => true to enforce a fixed text format for float values
  #
  # def self.prepare_summary_hash_by_ruport( params_hash = {} )
    # parent_id           = params_hash[:parent_id]
    # data_table          = params_hash[:data_table]
    # social_security_cost= params_hash[:social_security_cost]
    # account_wage        = params_hash[:account_wage]
    # total_expenses      = params_hash[:total_expenses]
    # currency_name       = params_hash[:currency_name]
    # do_float_formatting = params_hash[:do_float_formatting]
# 
    # [ :parent_id, :data_table, :social_security_cost,
      # :account_wage, :total_expenses, :currency_name ].each { |param_key|
      # raise( ArgumentError, "InvoiceRow.prepare_summary_hash(): missing #{param_key} parameter!", caller ) if params_hash[param_key].blank?
    # }
    # i = Invoice.find( parent_id )                   # At least, the header of the invoice must exist
    # unless i                                        # (This should never happen, since ActiveRecord throws an exception first:)
      # raise( ArgumentError, "InvoiceRow.prepare_summary_hash(): Invoice id=#{parent_id} not found!", caller )
    # end
    # unless data_table.instance_of?(Ruport::Data::Table) &&
           # (data_table.column_names == data_symbols())
      # raise ArgumentError, "InvoiceRow.prepare_summary_hash_by_ruport(): data_table invalid!", caller
    # end
# 
    # sum_cost_x_qty          = data_table.sigma(:taxable_amount)
    # subtotal                = data_table.sigma(:net_amount)
    # social_security_amount  = subtotal * social_security_cost
    # total_taxable_amount    = subtotal + social_security_amount
    # total_tax               = data_table.sigma { |row| 
                                # (row.net_amount.to_f + row.net_amount.to_f * social_security_cost.to_f) * (row.vat_tax_percent.to_f / 100.0)
                              # }
    # total                   = total_taxable_amount + total_tax
    # account_wage_amount     = total_taxable_amount * account_wage
    # grand_total             = total + account_wage_amount + total_expenses
# 
    # return {
      # :sum_cost_x_qty         => do_float_formatting ? Format.float_value( sum_cost_x_qty, InterfaceDataExport::CONVERTED_FLOAT2STRING_FIXED_PRECISION, CONVERTED_FLOAT2STRING_FIXED_LENGTH ) : sum_cost_x_qty.to_f,
      # :subtotal               => do_float_formatting ? Format.float_value( subtotal, InterfaceDataExport::CONVERTED_FLOAT2STRING_FIXED_PRECISION, CONVERTED_FLOAT2STRING_FIXED_LENGTH ) : subtotal.to_f,
      # :social_security_cost   => do_float_formatting ? Format.float_to_percent( social_security_cost, 0, CONVERTED_PERCENT2STRING_FIXED_LENGTH ) : social_security_cost.to_f,
      # :social_security_amount => do_float_formatting ? Format.float_value( social_security_amount, InterfaceDataExport::CONVERTED_FLOAT2STRING_FIXED_PRECISION, CONVERTED_FLOAT2STRING_FIXED_LENGTH ) : social_security_amount.to_f,
      # :total_taxable_amount   => do_float_formatting ? Format.float_value( total_taxable_amount, InterfaceDataExport::CONVERTED_FLOAT2STRING_FIXED_PRECISION, CONVERTED_FLOAT2STRING_FIXED_LENGTH ) : total_taxable_amount.to_f,
      # :total_tax              => do_float_formatting ? Format.float_value( total_tax, InterfaceDataExport::CONVERTED_FLOAT2STRING_FIXED_PRECISION, CONVERTED_FLOAT2STRING_FIXED_LENGTH ) : total_tax.to_f,
      # :total                  => do_float_formatting ? Format.float_value( total, InterfaceDataExport::CONVERTED_FLOAT2STRING_FIXED_PRECISION, CONVERTED_FLOAT2STRING_FIXED_LENGTH ) : total.to_f,
      # :account_wage           => do_float_formatting ? Format.float_to_percent( account_wage, 0, CONVERTED_PERCENT2STRING_FIXED_LENGTH ) : account_wage.to_f,
      # :account_wage_amount    => do_float_formatting ? Format.float_value( account_wage_amount, InterfaceDataExport::CONVERTED_FLOAT2STRING_FIXED_PRECISION, CONVERTED_FLOAT2STRING_FIXED_LENGTH ) : total_expenses.to_f,
      # :total_expenses         => do_float_formatting ? Format.float_value( total_expenses, InterfaceDataExport::CONVERTED_FLOAT2STRING_FIXED_PRECISION, CONVERTED_FLOAT2STRING_FIXED_LENGTH ) : total_expenses.to_f,
      # :grand_total            => do_float_formatting ? Format.float_value( grand_total, InterfaceDataExport::CONVERTED_FLOAT2STRING_FIXED_PRECISION, CONVERTED_FLOAT2STRING_FIXED_LENGTH ) : grand_total.to_f,
      # :currency_name          => currency_name
    # }
  # end
  # ----------------------------------------------------------------------------
  # FIXME ************************************^^^^^^^^^^^^^^^^^^^^^^^^^^^^


  # Prepares the +Ruport::Data::Table+ representing the collected data from +prepare_summary_hash+()
  # in a format easily displayed by the "summary view interface".
  #
  # === Parameters:
  # - +summary_hash+ =>
  #   The same kind of hash as the one resulting from a +prepare_summary_hash+() call.
  #
  # - +use_fixed_width_for_floats+ =>
  #   When true all float values will have a fixed width to be easily aligned in text files.
  #   Defaults to false.
  #
  def self.prepare_summary_table( summary_hash, use_fixed_width_for_floats = false )
    unless summary_hash.instance_of?(Hash) && (summary_hash.length == 12) &&
           (! summary_hash[ :currency_name ].nil?)
      raise ArgumentError, "InvoiceRow.prepare_summary_table(): invalid summary_hash parameter!", caller
    end

    data_for_the_table = [
      [ :subtotal,              :subtotal,                nil ],
      [ :social_security_cost,  :social_security_amount,  :social_security_cost ],
      [ :total_taxable_amount,  :total_taxable_amount,    nil ],
      [ :total_tax,             :total_tax,               nil ],
      [ :total,                 :total,                   nil ],
      [ :account_wage,          :account_wage_amount,     :account_wage ],
      [ :total_expenses,        :total_expenses,          nil ],
      [ :grand_total,           :grand_total,             nil ]
    ].each do |row_keys|
      raise(                                        # Prevent errors due to bad parameters:
        ArgumentError,
        "InvoiceRow.prepare_summary_table(): invalid summary_hash parameter!",
        caller
      ) if summary_hash[row_keys[1]].nil? || summary_hash[row_keys[0]].nil?
                                                    # Substitute each symbol placeholder with its appropriate value:
      row_keys[0] = (row_keys[0] == :grand_total) ?
                    I18n.t( row_keys[0], {:scope=>[:invoice_row]} ).upcase :
                    I18n.t( row_keys[0], {:scope=>[:invoice_row]} )
      row_keys[1] = use_fixed_width_for_floats ?
                    Format.float_value( summary_hash[row_keys[1]], 2, CONVERTED_FLOAT2STRING_FIXED_LENGTH ) :
                    summary_hash[row_keys[1]]
                                                    # Skip translation when row key #2 is nil:
      unless row_keys[2].nil?
        row_keys[2] = use_fixed_width_for_floats ?
                      Format.float_to_percent( summary_hash[row_keys[2]], 0, CONVERTED_PERCENT2STRING_FIXED_LENGTH ) :
                      summary_hash[row_keys[2]]
      end
    end

    summary_table_hash = {
      :column_names => [ I18n.t( :detailed_voices ), summary_hash[ :currency_name ].titleize, "%"],
      :data => data_for_the_table
    }
    return Ruport::Data::Table.new( summary_table_hash )
  end
  # ----------------------------------------------------------------------------


  protected


  def validate
    errors.add(:vat_tax,
               'should be a percentage expressed as a decimal value between -1.0 and 1.0'
    ) if vat_tax.to_f < -1.0 || vat_tax.to_f > 1.0

    errors.add(:discount,
               'should be a percentage expressed as a decimal value between -1.0 and 1.0'
    ) if discount.to_f < -1.0 || discount.to_f > 1.0
  end
  # ----------------------------------------------------------------------------


  private


  def self.find_rows_with_subtotals( parent_id, social_security_cost )
    sql_conditions = ['invoice_id = ?', parent_id]

    InvoiceRow.find(:all, {
        :conditions => sql_conditions,
        :select => "sum(unit_cost * quantity) as sum_cost_x_qty," +
                   "sum(unit_cost * quantity) - (sum(unit_cost * quantity) * discount) as sum_net_amount," +
                   "( (sum(unit_cost * quantity) - (sum(unit_cost * quantity) * discount)) +" +
                   "  (sum(unit_cost * quantity) - (sum(unit_cost * quantity) * discount)) * #{social_security_cost} ) * vat_tax as sum_net_tax," +
                   "le_currency_id, invoice_id",
        :group => 'invoice_id, le_currency_id'
    })
  end
  # ----------------------------------------------------------------------------
end
