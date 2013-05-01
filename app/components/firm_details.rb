#
# Firm details FormPanel implementation
#
# - author: Steve A.
# - vers. : 3.03.12.20130417
#
class FirmDetails < Netzke::Basepack::FormPanel

  model 'Firm'

  js_properties(
    :prevent_header => true,
    :track_reset_on_load => false,
    :border => false
  )


  def configuration
   super.merge(
     :min_width => 400,
     :width => 420
   )
  end


  # ASSERT: assuming current_user is always set for this grid component:
  items [
    {
      :layout => :column, :border => false,
      :items => [
        {
          :column_width => 1.00, :border => false,
          :defaults => { :label_width => 80 },
          :items => [
            {
              :xtype => :fieldcontainer, :field_label => I18n.t(:created_slash_updated_on),
              :layout => :hbox, :label_width => 125, :width => 350, :height => 18,
              :items => [
                { :name => :created_on,    :hide_label => true, :xtype => :displayfield, :width => 80},
                { :xtype => :displayfield, :value => ' / ',     :margin => '0 2 0 2' },
                { :name => :updated_on,    :hide_label => true, :xtype => :displayfield, :width => 120 }
              ]
            },
            { :name => :name, :field_label => I18n.t(:name), :width => 370, :field_style => 'font-size: 110%; font-weight: bold;' },
            { :name => :address, :field_label => I18n.t(:address), :width => 374 },
            { :name => :le_city__get_full_name, :field_label => I18n.t(:le_city, {:scope=>[:activerecord, :models]}), :width => 370 },
            { :name => :is_out_of_business, :field_label => I18n.t(:is_out_of_business),
              :default_value => false, :unchecked_value => 'false'
            },

            { :name => :tax_code, :field_label => I18n.t(:tax_code) },
            { :name => :vat_registration, :field_label => I18n.t(:vat_registration) },
            { :name => :phone_main, :field_label => I18n.t(:phone_main) },
            { :name => :phone_hq, :field_label => I18n.t(:phone_hq) },
            { :name => :phone_fax, :field_label => I18n.t(:phone_fax) },
            { :name => :e_mail, :field_label => I18n.t(:e_mail), :width => 320 },

            {
              :xtype => :fieldset, :title => I18n.t(:firm_type),
              :layout => :hbox, :width => 374, :defaults => {:margin => '0 10 2 0'},
              :items => [
                { :name => :is_user,       :hide_label => true, :box_label => I18n.t(:is_user),
                  :default_value => false, :unchecked_value => 'false'
                },
                { :name => :is_committer,  :hide_label => true, :box_label => I18n.t(:is_committer),
                  :default_value => false, :unchecked_value => 'false'
                },
                { :name => :is_partner,    :hide_label => true, :box_label => I18n.t(:is_partner),
                  :default_value => false, :unchecked_value => 'false'
                },
                { :name => :is_vendor,     :hide_label => true, :box_label => I18n.t(:is_vendor),
                  :default_value => false, :unchecked_value => 'false'
                }
              ]
            },

            { :name => :notes, :field_label => I18n.t(:notes), :width => 374 },
            { :name => :le_currency__display_symbol, :field_label => I18n.t(:le_currency, {:scope=>[:activerecord, :models]}), :width => 130,
              :default_value => AppParameter.get_default_currency_id() },

            { :name => :bank_name, :field_label => I18n.t(:bank_name), :width => 350 },
            { :name => :bank_abicab, :field_label => I18n.t(:bank_abicab) },
            { :name => :bank_cc, :field_label => I18n.t(:bank_cc) },
            { :name => :bank_notes, :field_label => I18n.t(:bank_notes), :width => 374 },

            { :name => :logo_image_big, :field_label => I18n.t(:logo_image_big), :width => 320 },
            { :name => :logo_image_short, :field_label => I18n.t(:logo_image_short), :width => 320 },
            { :name => :le_invoice_payment_type__get_full_name, :field_label => I18n.t(:le_invoice_payment_type), :width => 350 }
          ]
        }
      ]
    }
  ]
  # ---------------------------------------------------------------------------
end