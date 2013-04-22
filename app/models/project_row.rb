require 'ruport'
require 'common/format'
require 'framework/interface_data_export'


class ProjectRow < ActiveRecord::Base
  include InterfaceDataExport

  belongs_to :project
  belongs_to :human_resource
  belongs_to :le_currency
  belongs_to :project_milestone

  validates_associated :project
  validates_associated :human_resource
  validates_associated :le_currency
  validates_associated :project_milestone

  validates_presence_of :project_id
  validates_presence_of :date_entry

  validates_numericality_of :std_hours
  validates_numericality_of :ext_hours
  validates_numericality_of :km_tot
  validates_numericality_of :extra_expenses

  #--
  # Note: boolean validation via a typical...
  #
  #   validates_format_of :is_analysis_before_type_cast, :with => /[01]/, :message=> :must_be_0_or_1
  #
  # ...must *not* be used since the ExtJS grids convert internally the values from string/JSON text.


  scope :sort_project_row_by_resource,        lambda { |dir| order("human_resources.name #{dir.to_s}") }
  scope :sort_project_row_by_currency,        lambda { |dir| order("le_currencies.display_symbol #{dir.to_s}") }
  scope :sort_project_row_by_milestone,       lambda { |dir| order("project_milestones.name #{dir.to_s}") }


  # ---------------------------------------------------------------------------
  # Base methods:
  # ---------------------------------------------------------------------------
  #++

  # Returns the parent entity id value, if there is one. Usually inside the framework,
  # for ProjectRow is project_id, for InvoiceRow is invoice_id, for TeamRow is team_id
  # and so on.
  def get_parent_id()
    self.project_id
  end

  # Returns a shorter description (and safe, in the case of nil values) for the name associated with this data
  def get_full_name
    self.description.nil? ? '' : self.description
  end

  # Returns a verbose or formal description for the entry associated with this data
  def get_verbose_entry
    Format.a_date(self.date_entry) + ": #{get_full_name} (#{entry_type})"
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
    self.project.get_title_names()
  end
  # ---------------------------------------------------------------------------
  #++

  # Virtual attribute: verbose version of the boolean fields
  #
  def entry_type
    ('' << get_study + get_analysis + get_setup + get_develop + get_debug + get_deploy).strip
  end

  # Computed field: total hours assigned to this record
  def get_total_hours
    (self.std_hours.to_f + self.ext_hours.to_f)
  end

  # Retrieves associated currency symbol
  def get_currency_symbol
    self.le_currency.nil? ? "" : self.le_currency.display_symbol
  end

  # Retrieves the currency id for the associated Human Resource, returning the default currency
  # if not found.
  def get_human_resource_currency_id
    self.human_resource ? self.human_resource.get_default_currency_id() : AppParameter.get_default_currency_id() 
  end

  # Retrieves the currency id for the associated parent Project, returning the default currency
  # if not found.
  def get_project_currency_id
    self.project ? self.project.get_default_currency_id() : AppParameter.get_default_currency_id()
  end

  # Retrieves the default currency checking also for a default value inside app_parameters.
  #
  def get_default_currency_id
    self.human_resource ? self.human_resource.get_default_currency_id() : get_project_currency_id()
  end
  # ---------------------------------------------------------------------------

  # Retrieves the first human resource ID associated with the team instance defined by the parent Project
  def get_default_human_resource_id
    self.project ? (self.project.team ? self.project.team.get_first_human_resource_id() : nil) : nil
  end

  # Retrieves the last (most recently) used human resource ID for the current Project
  def get_last_used_human_resource_id
    self.project ? self.project.project_rows.last.human_resource_id : nil
  end
  # ---------------------------------------------------------------------------

  # Retrieves the associated Human Resource cost
  def cost_std_hour
    self.human_resource.nil? ? 0.0 : self.human_resource.cost_std_hour
  end
  # Retrieves the associated Human Resource cost
  def cost_ext_hour
    self.human_resource.nil? ? 0.0 : self.human_resource.cost_ext_hour
  end
  # Retrieves the associated Human Resource cost
  def cost_km
    self.human_resource.nil? ? 0.0 : self.human_resource.cost_km
  end
  # Retrieves the associated Human Resource cost
  def charge_std_hour
    self.human_resource.nil? ? 0.0 : self.human_resource.charge_std_hour
  end
  # Retrieves the associated Human Resource cost
  def charge_ext_hour
    self.human_resource.nil? ? 0.0 : self.human_resource.charge_ext_hour
  end
  # Retrieves the associated Human Resource cost
  def fixed_weekly_wage
    self.human_resource.nil? ? 0.0 : self.human_resource.fixed_weekly_wage
  end
  # Retrieves the associated Human Resource cost
  def charge_weekly_wage
    self.human_resource.nil? ? 0.0 : self.human_resource.charge_weekly_wage
  end
  # Retrieves the associated Human Resource cost
  def percentage_of_invoice
    self.human_resource.nil? ? 0.0 : self.human_resource.percentage_of_invoice
  end

  # Computes the total cost or total price associated with this record row.
  #
  # (It depends on whether +charge_std_hour+ and +charge_std_hour+ fields have
  # been used or not and if the current human resource does not have a pre-fixed
  # or percentage-based wage.)
  #
  def get_row_cost()
                                                    # For fixed or percentage-based wage, do not compute row costs:
    if (fixed_weekly_wage() + charge_weekly_wage() > 0.0 || percentage_of_invoice() > 0.0)
      0.0
    else                                            # Compute row cost:
      ( self.std_hours.to_f * (cost_std_hour() + charge_std_hour()) ) +
      ( self.ext_hours.to_f * (cost_ext_hour() + charge_ext_hour()) ) +
      ( self.km_tot.to_f * cost_km() ) + self.extra_expenses.to_f
    end
  end
  # ---------------------------------------------------------------------------
  #++

  # Returns an array of entry_type codes with their description.
  #
  def ProjectRow.get_entry_type_description_array
    [
      [ "Sty",    I18n.t(:study,    {:scope=>[:project_row]}) ],
      [ "A",      I18n.t(:analysis, {:scope=>[:project_row]}) ],
      [ "Set",    I18n.t(:setup,    {:scope=>[:project_row]}) ],
      [ "Dev",    I18n.t(:develop,  {:scope=>[:project_row]}) ],
      [ "Dbg",    I18n.t(:debug,    {:scope=>[:project_row]}) ],
      [ "DEPLOY", I18n.t(:deploy,   {:scope=>[:project_row]}) ]
    ]
  end
  # ---------------------------------------------------------------------------
  #++


  # ---------------------------------------------------------------------------
  # List Summary & Reporting:
  # ---------------------------------------------------------------------------
  #++


  # (Constant) Blank filler length of Floats converted to String values
  # Override value used instead of same-named constant of module InterfaceDataExport
  #
  CONVERTED_FLOAT2STRING_FIXED_LENGTH = 15

  # (Constant) Blank filler length of Integers (quantities) converted to String values
  # Override value used instead of same-named constant of module InterfaceDataExport
  #
  CONVERTED_INT2STRING_FIXED_LENGTH = 8


  ROW_COST_SYMS = [
      :cost_std_hour, :cost_ext_hour, :cost_km,
      :charge_std_hour, :charge_ext_hour,
      :fixed_weekly_wage, :charge_weekly_wage, :percentage_of_invoice
  ]

  BOOL_FIELDS_SYMS = [
      :is_analysis, :is_development, :is_deployment,
      :is_debug, :is_setup, :is_study
  ]

  # List of Column symbols or Label symbols that will receive the currency name in between brackets when
  # the text localization will be applied.
  #
  CURRENCY_SYMS = [
      :cost_std_hour, :cost_ext_hour, :cost_km,
      :charge_std_hour, :charge_ext_hour,
      :extra_expenses,
      :grouping_total_label,
      :esteemed_price,
      :totals,
      :fixed_weekly_wage, :charge_weekly_wage
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
      :human_resource, :date_entry, 
      :std_hours, :ext_hours, :km_tot, :extra_expenses,
      :entry_type,
      :project_milestone,
      :description, :notes
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
    header_symbols()
  end

  # Returns the list of the "detail" key +Symbols+ that will be used to create the result
  # of <tt>prepare_report_detail()</tt> and that will also be added to the list of all possible (localized)
  # "labels" returned by <tt>self.get_label_hash()</tt>.
  #
  def self.report_detail_symbols()
    header_symbols() + ProjectRow::ROW_COST_SYMS
  end


  # Prepares and returns the collected data for the "detail" phase of the reporting interface.
  # Returns a Ruport::Data::Table containing the formatted rows of records.
  #
  # === Options:
  #
  # - :+records+ =>
  #   an Array of record instances or an ActiveRecord::Relation result in which the detail data
  #   is assumed to be already filtered and sorted.
  #
  # - :+include_boolean_fields+ =>
  #   when +true+ (default: +false+) all the boolean fields of ProjectRow will be included
  #   in the data extraction and will be added as columns of the collected array of rows.
  #   Normally the boolean fields are "condensed" into a single codified "entry_type".
  #
  # - :+rjustification+ => numbers of blank fillers to be used for fixed-width floats;
  #   this is useful actually only for text file formatting, for PDF files ignore this option
  #   (justification is column based and layout-specific). Defaults to 0.
  #
  def self.prepare_report_detail( options_hash = {} )
    records = options_hash[:records]
    unless  records.kind_of?(ActiveRecord::Relation) || records.kind_of?(Array)
      raise ArgumentError, "ProjectRow.prepare_report_detail(): invalid records parameter!", caller
    end

    include_boolean_fields = options_hash[:include_boolean_fields]
    precision = InterfaceDataExport::CONVERTED_FLOAT2STRING_FIXED_PRECISION
    rjust     = options_hash[:rjustification].to_i
                                                    # Get Project/Firm default currency, in case we have to convert expenses:
    default_currency = (records[0]).project.get_default_currency_id()
                                                    # Collect and add the raw data:
    raw_data_syms = report_detail_symbols() +
                    ( include_boolean_fields ? ProjectRow::BOOL_FIELDS_SYMS : [] )

    array_of_raw_data = records.collect { |row|     # Convert extra expenses if they use another currency:
      if ( row.le_currency_id != default_currency )
        row.extra_expenses = LeCurrencyExchange.exchange_value( row.extra_expenses.to_f, row.le_currency_id, default_currency )
      end

      row.to_a_s(
        raw_data_syms,
        precision,
        rjust,
        Date::DATE_FORMATS[:agex_default_date],     # Use short date format even for date-time values
        Date::DATE_FORMATS[:agex_default_date]
      )
    }

    return Ruport::Data::Table.new( :data => array_of_raw_data, :column_names => raw_data_syms )
  end
  # ---------------------------------------------------------------------------


  # Computes an SQL sum among rows provided from the options or retrieved and grouped by the main
  # constraint for this entity (project_id) plus other filters (among these are human_resource_id
  # and starting_date; the data is filtered only when the +parent_id+ option is used and when any of
  # the filtering parameters defined below are given).
  #
  # Returns an hash containing the overall sum among all data rows so obtained, for all the columns
  # that are capable of being computed, in the form:
  #
  #     { :std_hours => std_hours_sum, :ext_hours => ext_hours_sum, :km_tot => km_tot_sum,
  #
  #       :cost_std_hour => cost_std_hour, :cost_ext_hour => cost_ext_hour, :cost_km => cost_km_sum,
  #       :charge_std_hour => charge_std_hour, :charge_ext_hour => charge_ext_hour_sum,
  #
  #       :extra_expenses => extra_expenses_sum, :currency_id => currency_id,
  #       :currency_name => currency_name }
  #
  # === Notes:
  # For each +human_resource_id+, the +fixed_weekly_wage+, +charge_fixed_wage+ and +percentage_of_invoice+
  # are ignored during the computation of the sum, since they must be computed elsewhere
  # while taking into account all the project rows and while using different grouping methods
  # (for the fixed weekly wage the grouping should use a range of dates).
  #
  # When "+human_resource_id+ <> +nil+" results are filtered according to its value, returning only
  # the sum for that particular group of rows. The same goes with +ending_date+, in which case
  # only the rows with a "date_entry <= ending_date" are selected.
  #
  # The default currency is retrieved using self.get_default_currency_id().
  #
  # === Required options: (only one of these is required; when both are provided +records+ has the precedence)
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
  # === Filtering parameters for when the +parent_id+ option is used:
  # - +date_from_lookup+  => filtering date range start (used only if present)
  # - +date_to_lookup+    => filtering date range end (used only if present)
  # - +human_resource_id+ => id of the "human resource" entity row that has to be used as secondary constraint to retrieve the data rows (used only if present)
  #
  def self.prepare_summary_hash( params_hash = {} )
    parent_id         = params_hash[:parent_id]
    records           = params_hash[:records]
    starting_date     = params_hash[:date_from_lookup]
    ending_date       = params_hash[:date_to_lookup]
    human_resource_id = params_hash[:human_resource_id]
    if parent_id.nil? && records.nil?
      raise(ArgumentError, "ProjectRow.prepare_summary_hash(): at least one of the parameters parent_id and records have to be supplied for the method to work.", caller)
    end
    if (! records.nil?) && (! records.kind_of?(ActiveRecord::Relation))
      raise ArgumentError, "ProjectRow.prepare_summary_hash(): invalid records parameter!", caller
    end
    if (! parent_id.nil?) && (parent_id.to_i < 1)
      raise ArgumentError, "ProjectRow.prepare_summary_hash(): invalid parent_id parameter!", caller
    end
    do_float_formatting = params_hash[:do_float_formatting] != nil

    if records                                      # == RECORDS: Do the grouping using ActiveRecord::Relation methods:
      subtotals = records.find(
          :all,
          :select => 'sum(std_hours) as std_hours_sum, sum(ext_hours) as ext_hours_sum, sum(km_tot) as km_tot_sum, sum(extra_expenses) as extra_expenses_sum, human_resource_id, le_currency_id, project_id',
          :group => 'project_id, human_resource_id, le_currency_id',
          :order => 'project_id, human_resource_id'
      )
    else                                            # == PARENT_ID: In case just a parent_id was provided, try to rebuild also additional filtering conditions:
      conditions = ['project_id = ?']
      keys = [parent_id]
      unless starting_date.nil?
        conditions << "(date_entry >= ?)" 
        keys << starting_date
      end
      unless ending_date.nil?
        conditions << "(date_entry <= ?)" 
        keys << ending_date
      end
      unless human_resource_id.nil?
        conditions << "(human_resource_id = ?)" 
        keys << human_resource_id
      end
      subtotals = ProjectRow.find(
          :all,
          :conditions => [conditions.join(' and '), keys].flatten,
          :select => 'sum(std_hours) as std_hours_sum, sum(ext_hours) as ext_hours_sum, sum(km_tot) as km_tot_sum, sum(extra_expenses) as extra_expenses_sum, human_resource_id, le_currency_id, project_id',
          :group => 'project_id, human_resource_id, le_currency_id',
          :order => 'project_id, human_resource_id'
      )
    end
                                                    # Get the default currency or its override and initialize sums: (this should never change among rows of a same project)
    default_currency  = subtotals.size == 0 ? AppParameter.get_default_currency_id() : subtotals[0].get_default_currency_id()
    std_hours_sum     = ext_hours_sum = km_tot_sum = extra_expenses_sum = cost_std_hour_sum = cost_ext_hour_sum = 
                        cost_km_sum = charge_std_hour_sum = charge_ext_hour_sum = 0.0
                                                    # Foreach group of human resources and currencies, compute total sums:
    subtotals.each { |row|
      human_resource_currency_id = row.get_human_resource_currency_id # (this can change from row to row)
# DEBUG
#      puts "\r\n---- ProjectRow::prepare_summary_hash(): inspecting subtotal row..."
      cost_std_hour       = LeCurrencyExchange.exchange_value( row.cost_std_hour.to_f, human_resource_currency_id, default_currency )
      cost_ext_hour       = LeCurrencyExchange.exchange_value( row.cost_ext_hour.to_f, human_resource_currency_id, default_currency )
      cost_km             = LeCurrencyExchange.exchange_value( row.cost_km.to_f, human_resource_currency_id, default_currency )
      charge_std_hour     = LeCurrencyExchange.exchange_value( row.charge_std_hour.to_f, human_resource_currency_id, default_currency )
      charge_ext_hour     = LeCurrencyExchange.exchange_value( row.charge_ext_hour.to_f, human_resource_currency_id, default_currency )
      std_hours_sum       += row.std_hours_sum.to_f
      ext_hours_sum       += row.ext_hours_sum.to_f
      km_tot_sum          += row.km_tot_sum.to_f
      cost_std_hour_sum   += cost_std_hour * row.std_hours_sum.to_f
      cost_ext_hour_sum   += cost_ext_hour * row.ext_hours_sum.to_f
      cost_km_sum         += cost_km * row.km_tot_sum.to_f
      charge_std_hour_sum += charge_std_hour * row.std_hours_sum.to_f
      charge_ext_hour_sum += charge_ext_hour * row.ext_hours_sum.to_f
# DEBUG
#      puts "    - cost_std_hour_sum: #{cost_std_hour * row.std_hours_sum.to_f}, cost_ext_hour_sum: #{cost_ext_hour * row.ext_hours_sum.to_f}"
#      puts "    - row.std_hours_sum: #{row.std_hours_sum.to_f}, row.cost_ext_hour: #{row.cost_ext_hour.to_f}, row.extra_expenses_sum: #{row.extra_expenses_sum.to_f}"
#      puts "    - human_resource_currency_id: #{human_resource_currency_id}, default_currency: #{default_currency}, row.le_currency_id: #{row.le_currency_id}"
      extra_expenses_sum  += LeCurrencyExchange.exchange_value( row.extra_expenses_sum.to_f, row.le_currency_id, default_currency )
    }
    grand_total_hash = {
      :std_hours        => std_hours_sum.to_f,
      :ext_hours        => ext_hours_sum.to_f,
      :km_tot           => km_tot_sum.to_f,
      :cost_std_hour    => cost_std_hour_sum.to_f,
      :cost_ext_hour    => cost_ext_hour_sum.to_f, 
      :cost_km          => cost_km_sum.to_f,
      :charge_std_hour  => charge_std_hour_sum.to_f,
      :charge_ext_hour  => charge_ext_hour_sum.to_f,
      :extra_expenses   => extra_expenses_sum.to_f
    }
    grand_total = ProjectRow.compute_grand_total( grand_total_hash )
# DEBUG
#    puts "    - grand_total_hash: #{grand_total_hash.inspect}"
#    puts "    - grand_total: #{grand_total.inspect}"
    result_hash = {
      :std_hours        => do_float_formatting ? Format.float_value( std_hours_sum.to_f, 1 ) : std_hours_sum.to_f,
      :ext_hours        => do_float_formatting ? Format.float_value( ext_hours_sum.to_f, 1 ) : ext_hours_sum.to_f,
      :km_tot           => do_float_formatting ? Format.float_value( km_tot_sum.to_f, 1 ) : km_tot_sum.to_f,
      :cost_std_hour    => do_float_formatting ? Format.float_value( cost_std_hour_sum.to_f, CONVERTED_FLOAT2STRING_FIXED_PRECISION ) : cost_std_hour_sum.to_f,
      :cost_ext_hour    => do_float_formatting ? Format.float_value( cost_ext_hour_sum.to_f, CONVERTED_FLOAT2STRING_FIXED_PRECISION ) : cost_ext_hour_sum.to_f, 
      :cost_km          => do_float_formatting ? Format.float_value( cost_km_sum.to_f, CONVERTED_FLOAT2STRING_FIXED_PRECISION ) : cost_km_sum.to_f,
      :charge_std_hour  => do_float_formatting ? Format.float_value( charge_std_hour_sum.to_f, CONVERTED_FLOAT2STRING_FIXED_PRECISION ) : charge_std_hour_sum.to_f,
      :charge_ext_hour  => do_float_formatting ? Format.float_value( charge_ext_hour_sum.to_f, CONVERTED_FLOAT2STRING_FIXED_PRECISION ) : charge_ext_hour_sum.to_f,
      :extra_expenses   => do_float_formatting ? Format.float_value( extra_expenses_sum.to_f, CONVERTED_FLOAT2STRING_FIXED_PRECISION ) : extra_expenses_sum.to_f, 
      :currency_id      => default_currency,
      :currency_name    => LeCurrency.get_name_by( default_currency ),
      :grand_total      => do_float_formatting ? Format.float_value( grand_total, CONVERTED_FLOAT2STRING_FIXED_PRECISION ) : grand_total.to_f
    }
# DEBUG
#    puts "\r\n---- ProjectRow::prepare_summary_hash(): inspecting result_hash..."
#    puts "    #{result_hash.inspect}\r\n===========================================================\r\n"

    return result_hash
  end
  # ----------------------------------------------------------------------------
  #++


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
  # FIXME Not used anymore. Deprecate or adapt.
  #
  def self.prepare_summary_table( summary_hash, use_fixed_width_for_floats = false )
    unless summary_hash.instance_of?(Hash) && (summary_hash.length == 12) &&
           (! summary_hash[ :currency_name ].nil?)
      raise ArgumentError, "ProjectRow.prepare_summary_table(): invalid summary_hash parameter!", caller
    end

    data_for_the_table = [
      [ :std_hours,         :std_hours,   :cost_std_hour ],
      [ :ext_hours,         :ext_hours,   :cost_ext_hour ],
      [ :km_tot,            :km_tot,      :cost_km ],
      [ :charge_std_hour,   nil,          :charge_std_hour ],
      [ :charge_ext_hour,   nil,          :charge_ext_hour ],
      [ :extra_expenses,    nil,          :extra_expenses ],
      [ :grand_total,       nil,          :grand_total ]
    ].each do |row_keys|
      raise(                                      # Prevent errors due to bad parameters:
        ArgumentError,
        "ProjectRow.prepare_summary_table(): invalid summary_hash parameter!",
        caller
      ) if summary_hash[row_keys[2]].nil? || summary_hash[row_keys[0]].nil?
                                                  # Substitute each symbol placeholder with its appropriate value:
      row_keys[0] = (row_keys[0] == :grand_total) ?
                    I18n.t( row_keys[0] ).upcase :
                    I18n.t( row_keys[0], {:scope=>[:project_row]} )
                                                  # Skip translation when row key #1 is nil:
      unless row_keys[1].nil?
        row_keys[1] = use_fixed_width_for_floats ?
                      Format.float_value( summary_hash[row_keys[1]], 2, CONVERTED_FLOAT2STRING_FIXED_LENGTH ) :
                      summary_hash[row_keys[1]] 
      end
      row_keys[2] = use_fixed_width_for_floats ?
                    Format.float_value( summary_hash[row_keys[2]], 2, CONVERTED_FLOAT2STRING_FIXED_LENGTH ) :
                    summary_hash[row_keys[2]]
    end

    summary_table_hash = {
      :column_names => [ I18n.t( :detailed_voices ), I18n.t( :qty ), summary_hash[ :currency_name ].titleize],
      :data => data_for_the_table
    }
    return Ruport::Data::Table.new( summary_table_hash )
  end
  # ---------------------------------------------------------------------------


  private


  def get_study
    self.is_study? ? "Sty " : ""
  end

  def get_analysis
    self.is_analysis? ? "A " : ""
  end

  def get_setup
    self.is_setup? ? "Set " : ""
  end

  def get_develop
    self.is_development? ? "Dev " : ""
  end

  def get_debug
    self.is_debug? ? "Dbg " : ""
  end

  def get_deploy
    self.is_deployment? ? "DEPLOY " : ""
  end


  # Computes the total project cost.
  # The total sum is computed using +prepare_summary_hash+ and can be filtered for a
  # specific human_resource_id or ending_date.
  # If the hash of sum results has already been computed, it can be passed to speed up the process.
  #
  # Parameters:
  #
  #   summary_hash : the resulting hash from a +prepare_summary_hash+ call.
  #
  def ProjectRow.compute_grand_total( summary_hash )
    total_cost = 0.0
    total_cost += summary_hash[:cost_std_hour] unless summary_hash[:cost_std_hour].nil?
    total_cost += summary_hash[:cost_ext_hour] unless summary_hash[:cost_ext_hour].nil?
    total_cost += summary_hash[:cost_km] unless summary_hash[:cost_km].nil?
    total_cost += summary_hash[:charge_std_hour] unless summary_hash[:charge_std_hour].nil?
    total_cost += summary_hash[:charge_ext_hour] unless summary_hash[:charge_ext_hour].nil?
    total_cost += summary_hash[:extra_expenses] unless summary_hash[:extra_expenses].nil?
    total_cost
  end
  # ----------------------------------------------------------------------------
  #++
end
