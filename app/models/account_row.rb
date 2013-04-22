# encoding: utf-8

require 'ruport'
require 'common/format'
require 'framework/interface_data_export'


class AccountRow < ActiveRecord::Base

  include InterfaceDataExport

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

  validates_associated :account

  validates_associated :le_currency
  validates_associated :recipient_firm

  # [Steve, 20120212] Validating le_user fails always because of validation requirements inside LeUser (password & salt)
#  validates_associated :user (it can be null)
  validates_associated :parent_le_account_row_type
  validates_associated :le_account_row_type
  validates_associated :le_account_payment_type


  validates_presence_of :account_id
  validates_presence_of :date_entry

  validates_presence_of :entry_value
  validates_numericality_of :entry_value

  validates_presence_of :description
  validates_length_of :description, :within => 1..255

  validates_length_of :check_number, :maximum => 80, :allow_nil => true


  scope :sort_account_row_by_currency,      lambda { |dir| order("le_currencies.display_symbol #{dir.to_s}") }
  scope :sort_account_row_by_payment_type,  lambda { |dir| order("le_account_payment_types.name #{dir.to_s}") }
  scope :sort_account_row_by_user,          lambda { |dir| order("le_users.name #{dir.to_s}") }
  scope :sort_account_row_by_recipient,     lambda { |dir| order("recipient_firms_account_rows.name #{dir.to_s}") }
  scope :sort_account_row_by_firm,          lambda { |dir| order("firms.name #{dir.to_s}") }
  scope :sort_account_row_by_parent_type,   lambda { |dir| order("le_account_row_types.name #{dir.to_s}") }
  scope :sort_account_row_by_type,          lambda { |dir| order("le_account_row_types_account_rows.name #{dir.to_s}") }
  # ---------------------------------------------------------------------------


  # Returns the parent entity id value, if there is one. Usually inside the framework,
  # for ProjectRow is project_id, for InvoiceRow is invoice_id, for TeamRow is team_id
  # and so on.
  def get_parent_id()
    self.account_id
  end

  # Returns a shorter description for the name associated with this data
  def get_full_name
    self.description.to_s
  end

  # Returns a verbose or formal description for the entry associated with this data
  def get_verbose_entry
    [
      entry_value.to_s.empty? ? nil : entry_value.to_s,
      (self.le_currency.nil? ? nil : self.le_currency.name),
      (get_full_name.empty? ? nil : get_full_name)
    ].compact.join(" ")
  end

  # Retrieves associated currency symbol
  def get_currency_symbol
    self.le_currency.nil? ? "" : self.le_currency.display_symbol
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
    self.account.get_title_names()
  end
  # ---------------------------------------------------------------------------

  # Retrieves associated account row type
  def get_account_row_type
    self.le_account_row_type.nil? ? "" : self.le_account_row_type.name
  end

  # Retrieves associated parent account row type
  def get_parent_account_row_type
    self.parent_le_account_row_type.nil? ? "" : self.parent_le_account_row_type.name
  end

  # Retrieves associated account payment type
  def get_account_payment_type
    self.le_account_payment_type.nil? ? "" : self.le_account_payment_type.name
  end
  # ---------------------------------------------------------------------------


  # Retrieves the default currency from the parent row if set.
  # In any case, the parent link column attribute must be present in current instance.
  #
  def get_default_currency_id
    raise "Account id not set for this row!" unless self.account
                                                    # Get default currency using parent method:
    self.account.get_default_currency_id()
  end
  # ---------------------------------------------------------------------------


  # ---------------------------------------------------------------------------
  # Data-Export & Reporting:
  # ---------------------------------------------------------------------------


  # Returns the text label to be used as a description for the result of groupings between
  # row instances of this entity.
  #
  # def self.grouping_label()
    # 'Current total amount'
  # end
  # # ---------------------------------------------------------------------------
# 
# 
  # # Returns a (constant) Array of symbols used as key reference for header fields or column titles.
  # # This header can then be used for both printable (PDF, TXT, ODT) and data (OUT, XML, whatever) export
  # # file formats.
  # #
  # # Note that these do not necessarily correspond to actual column names, but they will be nevertheless
  # # used as key indexes to process each row of the final data hash sent to the either the layout builders
  # # or the data export methods. The contract to assure field existance is delegated to the implementors
  # # or the utilizing methods.
  # #
  # def self.header_symbols()
    # [
      # :date_entry, :recipient_firm, :description,
      # :entry_value, :le_currency,
      # :parent_le_account_row_type, :le_account_row_type, :le_account_payment_type,
      # :check_number, :notes
    # ]
  # end
# 
  # # Returns a list of +Hash+ keys of any additional text label to be localized, different from any
  # # other existing record field or getter method already included in +report_header_symbols+ or
  # # +report_detail_symbols+ (since these are just referring to data fields and not to any other
  # # additional text that may be used in the report layout).
  # #
  # def self.report_label_symbols()
    # [
      # :meta_info_subject,
      # :meta_info_keywords,
      # :filtering_label,
      # :report_created_on,
      # :grouping_total_label
    # ]
  # end
  # ---------------------------------------------------------------------------
  
  ############à^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  # List of Column symbols or Label symbols that will receive the currency name in between brackets when
  # the text localization will be applied.
  #
  CURRENCY_SYMS = [
      :entry_value
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
      :date_entry, :recipient_firm, :description,
      :entry_value, :le_currency,
      :parent_le_account_row_type, :le_account_row_type, :le_account_payment_type,
      :check_number, :notes
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
      :date_entry, :recipient_firm, :description,
      :entry_value, :le_currency,
      :parent_le_account_row_type, :le_account_row_type, :le_account_payment_type,
      :check_number, :notes
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
  # === Options:
  #
  # - <tt>:records</tt> =>
  #   an Array of record instances on which the detail data must be collected and prepared.
  #   This must be already filtered and sorted accordingly, since no more sorting will
  #   be performed by this method.
  #
  # - <tt>:computed_sums</tt> =>
  #   sums and subtotals hash already computed on the dataset - see: self.prepare_summary_hash()
  #
  # - <tt>:date_from_lookup</tt> =>
  #   starting date value used to filter the dataset.
  #
  # - <tt>:date_to_lookup</tt> =>
  #   ending date value used to filter the dataset.
  #
  # - <tt>:currency_name</tt> =>
  #   the verbose name of the main currency used among the rows.
  #
  # - <tt>:rjustification</tt> => numbers of blank fillers to be used for fixed-width floats;
  #   this is useful actually only for text file formatting, for PDF files ignore this option
  #   (justification is column based and layout-specific). Defaults to 0.
  #
  def self.prepare_report_detail( options = {} )
    records           = options[:records]
    computed_sums     = options[:computed_sums]
    date_from_lookup  = options[:date_from_lookup]
    date_to_lookup    = options[:date_to_lookup]
    currency_name     = options[:currency_name]
    raise "prepare_report_detail(): a :records option is required, specifying all data records that have to be processed." if (! records.kind_of?(ActiveRecord::Relation))
    raise "prepare_report_detail(): a :computed_sums option is required, specifying an Hash of computed sums." unless computed_sums.instance_of?( Hash )
    raise "prepare_report_detail(): the Hash of computed sums must use the key :starting_total for the starting sum value." unless computed_sums.has_key?(:starting_total)
    raise "prepare_report_detail(): a :date_from_lookup option is required, specifying starting filtering date of the range of the dataset." if options[:date_from_lookup].blank?
    precision = InterfaceDataExport::CONVERTED_FLOAT2STRING_FIXED_PRECISION
    rjust     = options[:rjustification].to_i

    array_of_raw_data = [
        new_data_export_row(                        # Add a starting sum as first row:
            I18n.t(:starting_total, {:scope=>[:account_row]}),
            currency_name,
            Format.to_localized_string( computed_sums[:starting_total], precision, rjust ),
            Format.a_date( date_from_lookup )
        )
    ] + records.collect { |row|                     # Collect and add the raw data, converting also datetime stamps to simple dates:
      row.to_a_s( report_detail_symbols(), precision, rjust, Date::DATE_FORMATS[:agex_default_date] )
    }
                                                    # Build data set as a "reportable" table:
    data_table = Ruport::Data::Table.new( :data => array_of_raw_data, :column_names => report_detail_symbols() )
    data_table.remove_column( :le_currency )        # (If all rows have same currency, this column is boring)
                                                    # Add a summary row at the end of the table:
    sum_value = data_table.sigma( :entry_value )
    data_table << {
        :date_entry  => Format.a_date( date_to_lookup ),
        :description => "#{I18n.t(:grouping_total_label, {:scope=>[:account_row]} ).upcase} (#{currency_name}):",
        :entry_value => Format.to_localized_string( sum_value.to_f, precision, rjust )
    }

    return data_table
  end
  # ---------------------------------------------------------------------------


  # Prepares a custom output array for data export (CVS, TXT or PDF summary), using the
  # specified values for date_entry, description, currency and entry_value into an Array
  # structured as +data_symbols+.
  #
  # Useful for custom-added summary rows at the end or at the beginning of a report.
  # NOTE: some of the resulting array elements may be nil.
  #
  def self.new_data_export_row( description, currency_name, entry_value, date_entry = nil )
    header_symbols().collect do |sym|
      case sym
        when :description
          description
        when :le_currency
          currency_name
        when :entry_value
          entry_value
        when :date_entry
          date_entry
        when :notes
          description + ( date_entry.nil? ? "" : " @ " + date_entry )
        else
          nil
      end
    end
  end
  # ---------------------------------------------------------------------------


  # Computes a SQL sum among rows grouped by <tt>account_id, le_account_row_type_id</tt> and <tt>le_currency_id</tt>
  # and filtered by <tt>date_entry</tt>, if its value is not +nil+.
  #
  # Returns an hash containing the overall sum among *all* rows for *all* the summable columns,
  # in the form:
  #<tt>
  # {
  #    :subtotal_values  => </tt>Hash of subtotal sums, keyed by <tt>le_account_row_type_id</tt> values (0..n)<tt>,
  #    :subtotal_names   => </tt>Hash of descriptive names, keyed as above<tt>,
  #    :subtotal_order   => </tt>Array of the above keys, sorted by their corresponding names in alphabetical order<tt>,
  #    :grand_total      => </tt>grand total, computed among all the rows<tt>,
  #    :currency_id      => </tt>default currency id<tt>,
  #    :currency_name    => LeCurrency.get_name_by( default_currency )
  # }
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
  # - <tt>:date_from_lookup</tt> => filtering date range start
  #
  # - <tt>:date_to_lookup</tt> => filtering date range end
  #
  # - <tt>:do_float_formatting</tt> =>
  #   set this != +nil+ to convert to text and enforce a fixed text format for each float value.
  #
  def self.prepare_summary_hash( params_hash = {} )
    parent_id     = params_hash[:parent_id]
    records       = params_hash[:records]
    do_float_formatting = params_hash[:do_float_formatting] != nil
    starting_date = params_hash[:date_from_lookup]
    ending_date   = params_hash[:date_to_lookup]

    if parent_id.nil? && records.nil?
      raise(ArgumentError, "AccountRow.prepare_summary_hash(): at least one of the parameters parent_id and records have to be supplied for the method to work.", caller)
    end
    if (! records.nil?) && (! records.kind_of?(ActiveRecord::Relation))
      raise ArgumentError, "AccountRow.prepare_summary_hash(): invalid records parameter!", caller
    end
    if (! parent_id.nil?) && (parent_id.to_i < 1)
      raise ArgumentError, "AccountRow.prepare_summary_hash(): invalid parent_id parameter!", caller
    end

    if records                                      # Issuing an ActiveRelation filtering find is faster than a query:
      subtotals = records.joins(:le_account_row_type, :parent_le_account_row_type).find(
        :all,
        :select => 'sum(entry_value) as entry_subtot, le_account_row_types.name as category, le_account_row_type_id, le_currency_id, account_id',
        :group => 'account_id, le_account_row_type_id, le_currency_id',
        :order => 'account_id, category'
      )
      parent_id = records[0].account_id             # This will be used below, to compute the starting summary

    else                                            # In this case, we re-build the conditions for the dataset:
      conditions = ['account_id = ?']
      keys = [parent_id]
      unless starting_date.nil?
        conditions << "(date_entry >= ?)" 
        keys << starting_date
      end
      unless ending_date.nil?
        conditions << "(date_entry <= ?)" 
        keys << ending_date
      end

      subtotals = AccountRow.joins(:le_account_row_type, :parent_le_account_row_type).find(
          :all,
          :conditions => [conditions.join(' and '), keys].flatten,
          :select => 'sum(entry_value) as entry_subtot, le_account_row_types.name as category, le_account_row_type_id, le_currency_id, account_id',
          :group => 'account_id, le_account_row_type_id, le_currency_id',
          :order => 'account_id, category'
      )
    end

    grand_tot = 0.0                                 # Initialize the default currency or its override and the sums: (default currency should never change among rows of a same project)
    starting_tot = 0.0
    default_currency = 0
    subtot_values = {}
    subtot_names = {}
                                                    # Compute a starting summary if starting date is not null:
    if starting_date
      starting_summary = prepare_summary_hash( :parent_id => parent_id, :date_from_lookup => nil, :date_to_lookup => starting_date )
      starting_tot = starting_summary[:grand_total]
      default_currency = starting_summary[:currency_id]
    end
                                                    # Get the default currency or its override and initialize sums: (this should never change among rows of a same invoice)
    default_currency  = ( subtotals.size == 0 ? 
                          AppParameter.get_default_currency_id() :
                          subtotals[0].get_default_currency_id()
    ) unless default_currency > 0
                                                    # Foreach group of subtotals, compute total sums:
    subtotals.each { |row|
      subtot = LeCurrencyExchange.exchange_value( row.entry_subtot.to_f, row.le_currency_id, default_currency )
      key = row.le_account_row_type_id.nil? ? 0 : row.le_account_row_type_id
      name = row.category # (Without "joins" call it should be: "row.get_account_row_type")

      subtot_values[key] = subtot + subtot_values.fetch( key, 0 )
      subtot_values[key] = Format.float_value(
          subtot_values[key],
          InterfaceDataExport::CONVERTED_FLOAT2STRING_FIXED_PRECISION,
          InterfaceDataExport::CONVERTED_FLOAT2STRING_FIXED_LENGTH
      ) if do_float_formatting 
      subtot_names[key] = (name == '' ? I18n.t(:undefined) : name) unless subtot_names.has_key?(key)
      grand_tot += subtot
    }
    grand_tot = starting_tot + grand_tot
    if do_float_formatting
      starting_tot = Format.float_value(
            starting_tot,
            InterfaceDataExport::CONVERTED_FLOAT2STRING_FIXED_PRECISION,
            InterfaceDataExport::CONVERTED_FLOAT2STRING_FIXED_LENGTH
      ) 
      grand_tot = Format.float_value(
            grand_tot,
            InterfaceDataExport::CONVERTED_FLOAT2STRING_FIXED_PRECISION,
            InterfaceDataExport::CONVERTED_FLOAT2STRING_FIXED_LENGTH
      ) 
    end

    return {
      :starting_total   => starting_tot,
      :subtotal_values  => subtot_values,
      :subtotal_names   => subtot_names,
      # [Steve, 20120925] Currently, :subtotal_order is used only during the "subtotal bar graph"
      # presentation dialog, created inside the account_rows_grid component.
      :subtotal_order   => subtot_names.invert.sort.collect{ |el| el[1] },  # Hash sort result=[['benzina', 24],['biblioteca',12], ...]
      :grand_total      => grand_tot,
      :currency_id      => default_currency,
      :currency_name    => LeCurrency.get_name_by( default_currency )
    }
  end
  # ---------------------------------------------------------------------------
end
