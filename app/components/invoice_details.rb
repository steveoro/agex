#
# Specialized Invoice details form component implementation
#
# - author: Steve A.
# - vers. : 3.05.05.20131002
#
class InvoiceDetails < Netzke::Basepack::FormPanel

  model 'Invoice'

  js_properties(
    :prevent_header => true,
    :border => false
  )


  def configuration
   super.merge(
     :min_width => 750
   )
  end


  # ASSERT: assuming current_user is always set for this grid component:
  items [
    {
      :layout => :column, :border => false,
      :items => [
        {
          :column_width => 1.00, :border => false, :defaults => { :label_width => 110 },
          :items => [
            {
              :xtype => :fieldcontainer, :field_label => I18n.t(:created_slash_updated_on),
              :layout => :hbox, :width => 370,
              :items => [
                { :name => :created_on,    :hide_label => true, :xtype => :displayfield, :width => 120 },
                { :xtype => :displayfield, :value => ' / ',     :margin => '0 2 0 2' },
                { :name => :updated_on,    :hide_label => true, :xtype => :displayfield, :width => 120 }
              ]
            },
            { :name => :name, :field_label => I18n.t(:name), :width => 300,
              :field_style => 'font-size: 110%; font-weight: bold;'
            },
            {
              :xtype => :fieldcontainer, :field_label => I18n.t(:invoice_number),
              :layout => :hbox, :width => 500,
              :items => [
                { :name => :invoice_number, :hide_label => true, :width => 60,
                  :xtype => :numberfield, :field_style => 'text-align: right;', :format => '0',
                  :default_value => :get_next_invoice_number
                },
                { :xtype => :displayfield, :value => " / #{I18n.t(:date_invoice)}", :margin => '0 2 0 2' },
                { :name => :date_invoice, :hide_label => true, :width => 190,
                  :format => 'Y-m-d', :default_value => DateTime.now, :margin => '0 0 0 2'
                },
              ]
            },
            { :name => :description, :field_label => I18n.t(:description), :width => 750 },
            { :name => :recipient_firm__get_full_name, :field_label => I18n.t(:recipient_firm__get_full_name),
              :width => 400,
              # [20121121] For the combo-boxes to have a working query after the 4th char is entered in the edit widget,
              # a lambda statement must be used. Using a pre-computed scope from the Model class prevents Netzke
              # (as of this version) to append the correct WHERE clause to the scope itself (with an inline lambda, instead, it works).
              :scope => lambda {|rel| rel.committers.still_available.order("name ASC")}
            },
            { :name => :header_object, :field_label => I18n.t(:header_object), :width => 750,
              :xtype => :textareafield, :resizable => true },
            { :name => :is_fully_payed, :field_label => I18n.t(:is_fully_payed),
              :field_style => 'min-height: 13px; padding-left: 13px;',
              :default_value => false, :unchecked_value => 'false'
            },
            {
              :xtype => :fieldcontainer, :field_label => I18n.t(:vat_tax),
              :layout => :hbox, :width => 380,
              :items => [
                { :name => :vat_tax, :hide_label => true, :xtype => :numberfield, :field_style => 'text-align: right;',
                  :decimal_precision => 2, :decimal_separator => '.', :step => 0.01, :width => 60 },
                { :name => :formatted_vat_tax, :hide_label => true, :xtype => :displayfield,
                  :width => 100, :margin => '0 0 0 2' }
              ]
            },
            {
              :xtype => :fieldcontainer, :field_label => I18n.t(:social_security_cost),
              :layout => :hbox, :width => 380,
              :items => [
                { :name => :social_security_cost, :hide_label => true, :xtype => :numberfield,
                  :field_style => 'text-align: right;', :decimal_precision => 2, :decimal_separator => '.',
                  :step => 0.01, :width => 60 },
                { :name => :formatted_social_security_cost, :hide_label => true, :xtype => :displayfield,
                  :width => 100, :margin => '0 0 0 2' }
              ]
            },
            {
              :xtype => :fieldcontainer, :field_label => I18n.t(:account_wage),
              :layout => :hbox, :width => 380,
              :items => [
                { :name => :account_wage, :hide_label => true, :xtype => :numberfield,
                  :field_style => 'text-align: right;', :decimal_precision => 2, :decimal_separator => '.',
                  :step => 0.01, :width => 60 },
                { :name => :formatted_account_wage, :hide_label => true, :xtype => :displayfield,
                  :width => 100, :margin => '0 0 0 2' }
              ]
            },
            { :name => :le_invoice_payment_type__get_full_name, :field_label => I18n.t(:le_invoice_payment_type__get_full_name),
              # [20121121] See note above for the sorted combo boxes.
              :scope => lambda { |rel| rel.order("name ASC") },
              :width => 380 },
            {
              :xtype => :fieldcontainer, :field_label => I18n.t(:total_expenses),
              :layout => :hbox, :width => 380,
              :items => [
                { :name => :total_expenses, :hide_label => true, :xtype => :numberfield,
                  :field_style => 'text-align: right;', :decimal_precision => 2, :decimal_separator => '.',
                  :width => 100 },
                { :name => :le_currency__display_symbol, :hide_label => true, :width => 40, :margin => '0 0 0 2',
                  # [20121121] See note above for the sorted combo boxes.
                  :scope => lambda { |rel| rel.order("display_symbol ASC") },
                  :default_value => Netzke::Core.current_user.get_default_currency_id_from_firm()
                }
              ]
            },
            { :name => :notes, :field_label => I18n.t(:notes), :height => 60, :width => 750,
              :resizable => true
            }
          ]
        }
      ]
    }
  ]
  # ---------------------------------------------------------------------------
  # ---------------------------------------------------------------------------
end
