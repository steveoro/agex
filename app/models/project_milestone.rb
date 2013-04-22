require 'common/format'


class ProjectMilestone < ActiveRecord::Base

  belongs_to :project
  belongs_to :user, :class_name => "LeUser", :foreign_key => "user_id"
  belongs_to :human_resource
  belongs_to :depends_on,  :class_name  => "ProjectMilestone", 
                           :foreign_key => "depends_on_id"
#  acts_as_tree :foreign_key => "depends_on_id"

  validates_presence_of :project_id

  validates_associated :project
  validates_associated :human_resource
  validates_associated :depends_on
# FIXME SE ABILITATO FALLISCE LA VALIDATION xogni azione (compreso il new) (mentre gli altri select vanno bene lo stesso)
#  validates_associated :user (it can be null)


  validates_presence_of :name
  validates_length_of :name, :within => 1..40
  validates_uniqueness_of :name, :scope => :project_id, :message => :already_exists

  validates_length_of :module_names, :maximum => 255, :allow_nil => true

  validates_presence_of :esteemed_days
  validates_numericality_of :esteemed_days

  validates_length_of :projected_for_version, :maximum => 40, :allow_nil => true
  validates_length_of :implemented_in_version, :maximum => 40, :allow_nil => true


  scope :not_yet_implemented, where(:implemented_in_version => nil)

  scope :sort_project_milestone_by_project,     lambda { |dir| order("projects.name #{dir.to_s}, project_milestones.name #{dir.to_s}") }
  scope :sort_project_milestone_by_user,        lambda { |dir| order("le_users.name #{dir.to_s}, project_milestones.name #{dir.to_s}") }
# TODO TEST THIS:
  scope :sort_project_milestone_by_dependency,  lambda { |dir| order("depends_ons_project_milestones.name #{dir.to_s}, project_milestones.name #{dir.to_s}") }
  scope :sort_project_milestone_by_resource,    lambda { |dir| order("human_resources.name #{dir.to_s}, project_milestones.name #{dir.to_s}") }


  #-----------------------------------------------------------------------------
  # Base methods:
  #-----------------------------------------------------------------------------
  #++

  public

  # Returns the parent entity id value, if there is one. Usually inside the framework,
  # for ProjectRow is project_id, for InvoiceRow is invoice_id, for TeamRow is team_id
  # and so on.
  def get_parent_id()
    self.project_id
  end

  # Returns a shorter description for the name associated with this data
  def get_full_name
    self.name
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    self.description.nil? ? get_full_name : "#{get_full_name}: #{description}"
  end

  # Returns a verbose or formal description for the entry associated with this data
  def get_verbose_entry
     get_full_name + " (#{self.esteemed_days} / #{self.module_names}): #{entry_type}"
  end

  # Virtual attribute: returns true if the milestone has been set as reached.
  def is_done?
    ( !self.date_implemented.nil? ) &&              # Check also the validity of the value (comparison between Date and Time instances)
    (self.date_implemented.year >= self.created_on.year) &&
    (self.date_implemented.month >= self.created_on.month) &&
    (self.date_implemented.day >= self.created_on.day)
  end

  # Virtual attribute: verbose version of the boolean fields
  #
  def entry_type
    ('' << get_public + get_critical + get_urgent + get_structural + get_user_request + get_done).strip
  end
  # ---------------------------------------------------------------------------
  #--
end
