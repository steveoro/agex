class LeInvoiceRowUnit < ActiveRecord::Base

  validates_presence_of :name
  validates_length_of :name, :within => 1..20
  validates_uniqueness_of :name, :message => :already_exists
  #-----------------------------------------------------------------------------
  #++

        # Special ID codes:
        ###################

  # ID for row unit = hours
  HOUR_ID = 1

  # ID for row unit = km
  KM_ID   = 4
  
  # TODO [Steve, 20120506] Create DB seeds that assure the above values


  # Computes a shorter (but full) representative value of this instance's data.
  #
  def get_full_name()
    self.name.to_s
  end
end
