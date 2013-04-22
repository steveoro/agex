# encoding: utf-8

require 'common/format'
require 'ruport'


class Project < ActiveRecord::Base

  has_many :project_rows
  has_many :project_milestones

#  acts_as_tree :foreign_key => "project_id"
  belongs_to :project
  belongs_to :firm
  belongs_to :team
  belongs_to :le_currency

  belongs_to :partner_firm,   :class_name  => "Firm", 
                              :foreign_key => "partner_firm_id"
                              # Note that if we get too specific with conditions here, ActiveRecord nils out the associations
                              # rows that do not respond to the constraints, as in the case of having a non-vendor id nulled specifing
                              # for example :conditions => "((firms.is_committer = 1) or (firms.is_vendor = 1))".
                              # To filter out rows see the ActiveScaffold association conditions override in the Helper file.
  belongs_to :committer_firm, :class_name  => "Firm", 
                              :foreign_key => "committer_firm_id"

#  has_many :human_resources, :through => :project_rows, :uniq => true
# FIXME why this was introduced in the first place, anyway?

  validates_associated :project
  validates_associated :firm
  validates_associated :team
  validates_associated :le_currency
  validates_associated :partner_firm
  validates_associated :committer_firm

  validates_presence_of :codename
  validates_length_of :codename, :within => 1..20
  validates_presence_of :name
  validates_length_of :name, :within => 1..40
  validates_uniqueness_of :name, :scope => :firm_id, :message => :already_exists

  validates_presence_of :date_start

  validates_numericality_of :esteemed_price


  scope :still_open, where(:is_closed => false)

  scope :sort_project_by_parent,    lambda { |dir| order("projects_projects.name #{dir.to_s}, projects.name #{dir.to_s}") }
  scope :sort_project_by_currency,  lambda { |dir| order("le_currencies.display_symbol #{dir.to_s}, projects.name #{dir.to_s}") }
  scope :sort_project_by_firm,      lambda { |dir| order("firms.name #{dir.to_s}, projects.name #{dir.to_s}") }
  scope :sort_project_by_partner,   lambda { |dir| order("partner_firms.name #{dir.to_s}, projects.name #{dir.to_s}") }
  scope :sort_project_by_committer, lambda { |dir| order("committer_firms_projects.name #{dir.to_s}, projects.name #{dir.to_s}") }
  scope :sort_project_by_team,      lambda { |dir| order("teams.name #{dir.to_s}, projects.name #{dir.to_s}") }
  # ---------------------------------------------------------------------------


  # ---------------------------------------------------------------------------
  # Base methods:
  # ---------------------------------------------------------------------------
  #++


  # Computes a shorter description for the name associated with this data
  def get_full_name
    self.name.to_s
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
    [ self.get_full_name, (self.firm ? self.firm.get_full_name.split(' ')[0] : '') ]
  end

  # Uses +get_title_names+() to obtain a single string name usable as
  # base file name for many output reports or data exchange files created while removing
  # special chars that may conflict with legacy filesystems.
  #
  def get_base_name
    get_title_names().join("_").gsub(/[òàèùçé^!"'£$%&?.,;:§°<>]/,'').gsub(/[\s|]/,'_').gsub(/[\\\/=]/,'-')
  end
  # ---------------------------------------------------------------------------
  #++

  # Retrieves associated Parent project name
  def get_parent_project_name
    self.project.nil? ? "" : self.project.get_full_name
  end

  # Retrieves associated firm name
  def get_firm_name
    self.firm.nil? ? "" : self.firm.get_full_name
  end

  # Retrieves associated Partner firm name
  def get_partner_name
    self.partner_firm.nil? ? "" : self.partner_firm.get_full_name
  end

  # Retrieves associated Committer firm name
  def get_committer_name
    self.committer_firm.nil? ? "" : self.committer_firm.get_full_name
  end

  # Retrieves associated team name
  def get_team_name
    self.team.nil? ? "" : self.team.get_full_name
  end

  # Retrieves associated currency symbol
  def get_currency_symbol
    self.le_currency.nil? ? "" : self.le_currency.display_symbol
  end

  # Retrieves associated currency name
  def get_currency_name
    self.le_currency.nil? ? "" : self.le_currency.name
  end
  # ---------------------------------------------------------------------------

  # Retrieves the default team id
  #
  def get_default_team_id
    team = Team.first.where( :available => true )
    team ? team.id : nil
  end

  # Retrieves the default currency checking also for a default value inside app_parameters.
  #
  def get_default_currency_id
    self.firm ? self.firm.get_default_currency_id() : AppParameter.get_default_currency_id()
  end
  # ---------------------------------------------------------------------------

  # Virtual attribute: returns the formatted esteemed price for this project.
  def esteemed_price_with_currency
    self.esteemed_price.to_s + ' ' + get_currency_symbol()
  end

  # Virtual attribute: returns the formatted date range (start ... end) for this project.
  def date_range
    Format.a_date( self.date_start ) + ' ... ' + Format.a_date( self.date_end )
  end
  # ---------------------------------------------------------------------------
  #++


  # ---------------------------------------------------------------------------
  # List Summary & Reporting:
  # ---------------------------------------------------------------------------
  #++


  # Returns a list of +Hash+ keys of any additional text label to be localized, different from any
  # other existing record field or getter method already included in +report_header_symbols+ or
  # +report_detail_symbols+ (since these are just referring to data fields and not to any other
  # additional text that may be used in the report layout).
  #
  def self.report_label_symbols()
    [
      :meta_info_subject,
      :meta_info_keywords,
      :filtering_label,
      :report_created_on,
      :resource_summary_title,
      :activity_summary_title,
      :global_summary_title,
      :totals,
      :resource
    ]
  end

  # Returns the list of "header" +Hash+ keys (the +Array+ of +Symbols+) that will be used to create the result
  # of <tt>prepare_report_header_hash()</tt> and that will also be added to the list of all possible (localized)
  # "labels" returned by <tt>self.get_label_hash()</tt>.
  #
  def self.report_header_symbols()
    [
      :name,
      :codename,
      :grouping_total_label,
      :parent_project,
      :description,
      :firm,
      :partner,
      :committer,
      :team_group,
      :date_start,
      :date_end,
      :esteemed_price,
      :has_gone_gold,
      :is_closed,
      :has_been_invoiced,
      :is_a_demo,
      :notes
    ]
  end

  # Prepares and returns the result hash containing the header data fields specified
  # in the <tt>report_header_symbols()</tt> list.
  #
  def prepare_report_header_hash()
    {
      :name                   => self.get_full_name,
      :codename               => self.codename,
      :grouping_total_label   => I18n.t( :grouping_total_label, :scope =>[:project_row] ),
      :parent_project         => get_parent_project_name(),
      :description            => self.description,
      :firm                   => get_firm_name(),
      :partner                => get_partner_name(),
      :committer              => get_committer_name(),
      :team_group             => get_team_name(),
      :date_start             => Format.a_date( self.date_start ),
      :date_end               => Format.a_date( self.date_end ),
      :esteemed_price         => self.esteemed_price.to_s + ' ' + get_currency_name,
      :has_gone_gold          => self.has_gone_gold?,
      :is_closed              => self.is_closed?,
      :has_been_invoiced      => self.has_been_invoiced?,
      :is_a_demo              => self.is_a_demo?,
      :notes                  => self.notes
    }
  end


  # Builds up an Hash that can be used to create a summary table containing the values of the summary_symbols()
  # for each one of the row instances specified with the parameters.
  #
  # This hash can then be sent to prepare_summary_table() to obtain the actual summary table to be displayed.
  #
  # === Parameters:
  # - :+records+ => an Array of record rows to be processed
  #
  def self.prepare_summary_hash( params_hash = {} )
    records = params_hash[:records]
    unless  records.kind_of?(ActiveRecord::Relation) || records.kind_of?(Array)
      raise ArgumentError, "Project.prepare_summary_hash(): invalid records parameter!", caller
    end
    return {} if params_hash[:records].size == 0    # (Bail out if there's nothing to do)
    summary_rows  = []
    currency_name = nil
                                                    # Loop on records, gather data for each summary row:
    records.each { |project|
      summary_hash = ProjectRow.prepare_summary_hash( :parent_id => project.id )
      summary_rows << [
        project.get_full_name,
        project.get_firm_name,
        project.get_committer_name,
        summary_hash[:std_hours],
        summary_hash[:ext_hours],
        summary_hash[:km_tot],
        summary_hash[:extra_expenses],
        summary_hash[:grand_total]                  # (Currency fields @ #6, #7 must be formatted only after usage, below)
      ]                                             # Store currency name as soon as you have it:
      currency_name = summary_hash[:currency_name] if currency_name.nil?
    }                                               # Finally, create and add a grand total summary row at the end:
    total_std_hours = summary_rows.collect { |a| a[3] }.inject {|sum, v| sum + v}
    total_ext_hours = summary_rows.collect { |a| a[4] }.inject {|sum, v| sum + v}
    total_km_tot = summary_rows.collect { |a| a[5] }.inject {|sum, v| sum + v}
    total_extra_expenses = summary_rows.collect { |a| a[6] }.inject {|sum, v| sum + v}
    grand_total = summary_rows.collect { |a| a[7] }.inject {|sum, v| sum + v}

    summary_rows << [ I18n.t(:projects_total).upcase + ':', nil, nil, total_std_hours, total_ext_hours,
                      total_km_tot, total_extra_expenses, grand_total ]
    return {
      :column_names => (
        [
          :name, :firm_id, :committer_firm_id,
          :std_hours, :ext_hours,
          :km_tot, :extra_expenses
        ].collect! { |sym|
            I18n.t( sym, {:scope=>[:project_row]} )
        } << "#{I18n.t(:grand_total)} (#{currency_name})"
      ),
      :data => summary_rows,
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
    unless summary_hash.kind_of?(Hash) && (summary_hash.keys - [ :column_names, :data, :currency_name ] == [])
      raise ArgumentError, "Project.prepare_summary_table(): invalid summary_hash parameter!", caller
    end
                                                    # Apply fixed format if requested:
    formatted_summary_hash = {
      :column_names => summary_hash[:column_names],
      :data => summary_hash[:data].nil? ? nil : summary_hash[:data].each{ |row|
        row[6] = use_fixed_width_for_floats ? Format.float_value( row[6] ) : row[6] # (this is :extra_expenses from the Hash computed with the method above)
        row[7] = use_fixed_width_for_floats ? Format.float_value( row[7] ) : row[7] # (this is :grand_total from the Hash computed with the method above)
      }
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
    unless  records.kind_of?(ActiveRecord::Relation) || records.kind_of?(Array)
      raise ArgumentError, "Project.prepare_summary_table_without_amounts(): invalid records list!", caller
    end
    return {} if records.size == 0                  # (Bail out if there's nothing to do)
    summary_rows = []
                                                    # Loop on records, gather data for each summary row:
    records.each { |project|
      summary_rows << [
        project.get_full_name,
        project.get_firm_name,
        project.get_committer_name,
      ]
    }
    summary_table_hash = {
      :column_names => [ :name, :firm_id, :committer_firm_id ].collect! { |s| I18n.t(s, {:scope=>[:project_row]}) },
      :data => summary_rows
    }

    return Ruport::Data::Table.new( summary_table_hash )
  end
  #-----------------------------------------------------------------------------
  #++
end
