# encoding: utf-8

require 'common/format'


class Account < ActiveRecord::Base

  has_many :account_rows

  belongs_to :firm

  validates_associated :firm

  validates_presence_of :name
  validates_length_of :name, :within => 1..20
  validates_uniqueness_of :name, :scope => :firm_id, :message => :already_exists

  validates_length_of :description, :maximum => 80, :allow_nil => true
  # ---------------------------------------------------------------------------


  # Computes a shorter description for the name associated with this data
  def get_full_name
    self.name.nil? ? "" : self.name
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    self.description.nil? ? get_full_name : self.description
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
    [
      self.get_verbose_name,
      ( self.firm ? self.firm.get_full_name.split(' ')[0] : '' )
    ]
  end

  # Uses +get_title_names+() to obtain a single string name usable as
  # base file name for many output reports or data exchange files created while removing
  # special chars that may conflict with legacy filesystems.
  #
  def get_base_name
    get_title_names().join("_").gsub(/[òàèùçé^!"'£$%&?.,;:§°<>]/,'').gsub(/[\s|]/,'_').gsub(/[\\\/=]/,'-')
  end


  # Retrieves firm name
  def get_firm_name
    self.firm.nil? ? "" : self.firm.get_full_name
  end
  # ---------------------------------------------------------------------------

  # Retrieves associated currency symbol
  def get_currency_symbol
    currency_id = get_default_currency_id()
    begin
      LeCurrency.find( currency_id ).display_symbol
    rescue
      ""
    end
  end

  # Retrieves associated currency name
  def get_currency_name
    currency_id = get_default_currency_id()
    begin
      LeCurrency.find( currency_id ).name
    rescue
      ""
    end
  end
  # ---------------------------------------------------------------------------

  # Retrieves the default currency from this account's firm_id, if set, or else it
  # searches for a default value (or its override) inside app_parameters.
  #
  def get_default_currency_id
    self.firm ? self.firm.get_default_currency_id() : AppParameter.get_default_currency_id()
  end
  # ---------------------------------------------------------------------------


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
      :report_created_on,
      :filtering_label,
      :meta_info_subject,                           # (used only by PDF layout)
      :meta_info_keywords,                          # (used only by PDF layout)
      :grouping_total_label,                        # (i.e. "grand total")
      :grouping_totals_label                        # (used as stats/items total summary title)
    ]
  end

  # Returns the list of "header" +Hash+ keys (the +Array+ of +Symbols+) that will be used to create the result
  # of <tt>prepare_report_header_hash()</tt> and that will also be added to the list of all possible (localized)
  # "labels" returned by <tt>self.get_label_hash()</tt>.
  #
  def self.report_header_symbols()
    [
      :description,
      :get_firm_name
    ]
  end


  # Prepares and returns the result hash containing the header data fields specified
  # in the <tt>report_header_symbols()</tt> list.
  #
  def prepare_report_header_hash()
    {
      :description      => description,
      :get_firm_name    => firm.get_full_name
    }
  end
  # ---------------------------------------------------------------------------
end
