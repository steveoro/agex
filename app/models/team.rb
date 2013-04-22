require 'common/format'


class Team < ActiveRecord::Base
  has_many :team_rows
  has_many :human_resources, :through => :team_rows

  belongs_to :firm

  validates_associated :firm

  validates_presence_of :name
  validates_length_of :name, :within => 1..20
  validates_uniqueness_of :name, :scope => :firm_id, :message => :already_exists

  validates_length_of :description, :maximum => 80, :allow_nil => true

  #--
  # Note: boolean validation via a typical...
  #
  #   validates_format_of :is_no_more_available_before_type_cast, :with => /[01]/, :message=> :must_be_0_or_1
  #
  # ...must *not* be used since the ExtJS grids convert internally the values from string/JSON text.


  scope :still_available, where(:is_no_more_available => false)

  scope :sort_team_by_firm,   lambda { |dir| order("firms.name #{dir.to_s}, teams.name #{dir.to_s}") }


  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------
  #++

  # Computes a shorter description for the name associated with this data
  def get_full_name
    self.name
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    get_full_name + (self.description.nil? ? "" : ": " + self.description)
  end
  # ---------------------------------------------------------------------------


  # Returns the number of all the human resources associated with this team that are still available
  def get_available_team_row_count
    HumanResource.joins(:team_rows).still_available.where( ['team_id = ?', self.id] ).count
  end

  # Retrieves the first human resource associated with this team instance
  def get_first_human_resource_id
    if self.team_rows                               # (Every TeamRow has at least 1 human resource associated with it)
      first_hr = HumanResource.joins(:team_rows).still_available.where( ['team_id = ?', self.id] ).first
      ( first_hr ? first_hr.id : nil )
    else
      nil
    end
  end
  # ---------------------------------------------------------------------------
end
