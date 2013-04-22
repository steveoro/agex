class LeCurrencyExchange < ActiveRecord::Base

  self.table_name = 'le_currency_exchange'

  belongs_to :source_currency,      :class_name => "LeCurrency", :foreign_key => "source_currency_id"
  belongs_to :destination_currency, :class_name => "LeCurrency", :foreign_key => "destination_currency_id"

  validates_associated :source_currency
  validates_presence_of :source_currency

  validates_associated :destination_currency
  validates_presence_of :destination_currency

  validates_numericality_of :factor


  scope :sort_exchange_by_source, lambda { |dir| order("le_currencies.display_symbol #{dir.to_s}") }
  scope :sort_exchange_by_destination, lambda { |dir| order("destination_currencies_le_currency_exchange.display_symbol #{dir.to_s}") }


  #-----------------------------------------------------------------------------
  # Base methods:
  #-----------------------------------------------------------------------------
  #++


  # Computes a shorter (but full) representative value of this instance's data.
  #
  def get_full_name()
    self.source_currency.name.to_s + ' => ' + self.destination_currency.name.to_s
  end
  #-----------------------------------------------------------------------------
  #++

  # Converts a value from a currency to an another. Does nothing if the source and
  # destination ids are the same.
  # This method seeks only the row having the latest date for the exchange rate.
  #
  def LeCurrencyExchange.exchange_value( value, from_currency_id, to_currency_id )
    factor = 1.0
                                                    # Valid and different ids?
    if from_currency_id && to_currency_id && (from_currency_id != to_currency_id)
                                                    # Search for an exchange factor, either from_currency_id |=> to_currency_id
                                                    # or the opposite, using latest change date:
      row = LeCurrencyExchange.find( :first,
        :conditions => ["((source_currency_id = ?) AND (destination_currency_id = ?)) OR " +
                        "((source_currency_id = ?) AND (destination_currency_id = ?))",
                        from_currency_id, to_currency_id,
                        to_currency_id, from_currency_id
                       ],
        :order => "date_exchange DESC"
      )

      if row
        if ( from_currency_id == row.source_currency_id )
          factor = row.factor
                                                    # In case only the opposite is found ( destination |=> source ), 
        else                                        # use 1/factor for the exchange:
          factor = 1.0 / row.factor
        end
      end                                           # (when no row is found, factor is simply 1.0)
    end

    (value.to_f * factor)
  end
  #-----------------------------------------------------------------------------
  #++
end
