class LeCurrency < ActiveRecord::Base

  validates_presence_of :name
  validates_length_of :name, :within => 1..20
  validates_uniqueness_of :name, :message => :already_exists

  validates_length_of :description, :maximum => 80

  validates_presence_of :display_symbol
  validates_length_of :display_symbol, :within => 1..10

  validates_presence_of :value_format
  validates_length_of :value_format, :within => 1..20
  # ----------------------------------------------------------------------------
  #++

  # Computes a shorter (but full) representative value of this instance's data.
  #
  def get_full_name()
    self.name.to_s
  end
  # ----------------------------------------------------------------------------
  #++

  # Retrieves the associated display symbol given the row id.
  # Returns an empty string if not found.
  #
  def LeCurrency.get_symbol_by( id )
    if id && ( result = LeCurrency.find(:first, :conditions => "id=#{id}") ) # avoid raising an exception, simply returning null if not found
      result.display_symbol
    else
      ''
    end
  end

  # Retrieves the name given the row id.
  # Returns an empty string if not found.
  #
  def LeCurrency.get_name_by( id )
    if id && ( result = LeCurrency.find(:first, :conditions => "id=#{id}") ) # avoid raising an exception, simply returning null if not found
      result.name
    else
      ''
    end
  end
  #-----------------------------------------------------------------------------
  #++
end
