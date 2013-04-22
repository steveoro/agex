class LeContactType < ActiveRecord::Base

  validates_presence_of :name
  validates_length_of :name, :within => 1..20
  validates_uniqueness_of :name, :message => :already_exists
  #-----------------------------------------------------------------------------
  #++

  # Computes a shorter (but full) representative value of this instance's data.
  #
  def get_full_name()
    self.name.to_s
  end
end
