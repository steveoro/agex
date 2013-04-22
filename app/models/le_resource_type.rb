class LeResourceType < ActiveRecord::Base

  validates_presence_of :name
  validates_length_of :name, :within => 1..20
  validates_uniqueness_of :name, :message => :already_exists

  validates_length_of :description, :maximum => 80, :allow_nil => true


  #-----------------------------------------------------------------------------
  # Base methods:
  #-----------------------------------------------------------------------------
  #++


  # Computes a shorter description for the name associated with this data
  def get_full_name
    self.name.to_s
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    [
      (name.empty? ? nil : name),
      (description.empty? ? nil : description)
    ].compact.join(": ")
  end
  #-----------------------------------------------------------------------------
  #++
end
