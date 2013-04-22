require 'common/format'


class TeamRow < ActiveRecord::Base
  belongs_to :team
  belongs_to :human_resource

  validates_presence_of :team_id
  validates_presence_of :human_resource_id

  validates_associated :team
  validates_associated :human_resource


  scope :still_available, joins(:human_resource).where(['human_resources.is_no_more_available = ?', false])

  scope :sort_team_row_by_resource,             lambda { |dir| order("human_resources.name #{dir.to_s}") }
  scope :sort_team_row_by_is_no_more_available, lambda { |dir| order("human_resources.is_no_more_available #{dir.to_s}") }

  #--
  # ---------------------------------------------------------------------------
  # Base methods:
  # ---------------------------------------------------------------------------
  #++

  # Returns the parent entity id value, if there is one. Usually inside the framework,
  # for ProjectRow is project_id, for InvoiceRow is invoice_id, for TeamRow is team_id
  # and so on.
  def get_parent_id()
    self.team_id
  end

  # Computes a shorter description for the name associated with this data
  def get_full_name
    self.team.nil? ? "" : self.team.get_full_name
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    get_full_name + (self.human_resource.nil? ? "" : ": " + self.human_resource.get_full_name)
  end
  # ---------------------------------------------------------------------------
  #++

  # Retrieves the +is_no_more_available+ flag from the human_resource association
  def get_is_no_more_available
    self.human_resource.nil? ? false : self.human_resource.is_no_more_available
  end
 
  # Computes a verbose list for the costs associated with this data
  def get_verbose_costs
    self.human_resource.nil? ? "" : self.human_resource.get_verbose_costs()
  end
  # ---------------------------------------------------------------------------
end
