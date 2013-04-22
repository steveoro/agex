#
# Custom Invoice Management Panel component implementation.
#
# - author: Steve A.
# - vers. : 0.34.20130214
#
# == Params
#
# :+record_id+ must be set during component configuration and must point to the current header's Invoice.id
#
class InvoiceManagePanel < Netzke::Basepack::BorderLayoutPanel

  js_properties(
    :prevent_header => true,
    :header => false,
    :border => true
  )


  def configuration
    super.merge(
      :persistence => true,
      :min_width => 790,
      :items => [
        :invoice_header.component( :region => :center ),
        :invoice_rows.component( :region => :south )
      ]
    )
  end
  # ---------------------------------------------------------------------------

  MANAGE_HEADER_HEIGHT = 320                        # this is referenced also more below


  component :invoice_header do
    {
      :class_name => "InvoiceDetails",
      :record_id => config[:record_id],
      :width => 780,
      :min_height => 200,
      :mode => :lockable,
      :height => MANAGE_HEADER_HEIGHT
    }
  end

  component :invoice_rows do
    {
      :class_name => "InvoiceRowsGrid",
      :scope => [ "invoice_id = ?", config[:record_id] ],

      :default_currency_id => config[:default_currency_id],
      :invoice_id => config[:record_id],

      :strong_default_attrs => {
        :invoice_id => config[:record_id]
      },
      :width => 780,
      :split => true
    }
  end
  # ---------------------------------------------------------------------------
end
