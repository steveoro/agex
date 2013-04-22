#
# Specialized Project details form component implementation
#
# - author: Steve A.
# - vers. : 3.03.14.20130419
#
class ProjectDetails < Netzke::Basepack::FormPanel

  model 'Project'

  js_properties(
    :prevent_header => true,
    :border => false
  )


  def configuration
   super.merge(
     :min_width => 910,
     :min_height => 120
   )
  end


  # ASSERT: assuming current_user is always set for this grid component:
  items [
    {
      :layout => :column, :border => false,
      :items => [
        {
          :column_width => 0.50, :border => false,
          :items => [
            { :name => :codename,           :field_label => I18n.t(:codename) },
            { :name => :name,               :field_label => I18n.t(:name),
              :field_style => 'font-size: 110%; font-weight: bold;' },
            { :name => :project__codename,  :field_label => I18n.t(:project__codename) },
            # [Steve, 20120201] (scope definitions can be found inside the Firm model)
            { :name => :firm__get_full_name,            :field_label => I18n.t(:developer_firm),
              :width => 400, :scope => lambda {|rel| rel.house_firms.still_available},
              :default_value => Netzke::Core.current_user.firm_id },
            { :name => :partner_firm__get_full_name,    :field_label => I18n.t(:partner_firm__get_full_name),
              :width => 400, :scope => lambda {|rel| rel.partners.still_available} },
            { :name => :committer_firm__get_full_name,  :field_label => I18n.t(:committer_firm__get_full_name),
              :width => 400, :scope => lambda {|rel| rel.committers.still_available} }
          ]
        },
        {
          :column_width => 0.50, :border => false,
          :items => [
            { :name => :team__name,         :field_label => I18n.t(:team__name), :label_width => 125,
              :margin => '0 0 2 0', :scope => lambda { |rel|
                # [Steve, 20120201] (scope definitions can be found inside the Team model)
                rel.still_available.where(
                  ['(firm_id = ?) OR (firm_id = NULL)', Netzke::Core.current_user.firm_id]
                )}
            },
            {
              :xtype => :fieldcontainer, :field_label => I18n.t(:created_slash_updated_on),
              :layout => :hbox, :label_width => 125, :width => 400,
              :items => [
                { :name => :created_on,         :hide_label => true, :xtype => :displayfield, :width => 120 },
                { :xtype => :displayfield,      :value => ' / ', :margin => '0 2 0 2' },
                { :name => :updated_on,         :hide_label => true, :xtype => :displayfield, :width => 120 }
              ]
            },
            {
              :xtype => :fieldcontainer, :field_label => I18n.t(:activity_start_end),
              :layout => :hbox, :label_width => 125, :width => 450,
              :items => [
                { :name => :date_start,         :hide_label => true, :width => 150,
                  :default_value => DateTime.now },
                { :xtype => :displayfield,      :value => '...', :margin => '0 2 0 2' },
                { :name => :date_end,           :hide_label => true, :width => 150 }
              ]
            },
            {
              :xtype => :fieldcontainer, :field_label => I18n.t(:esteemed_price),
              :layout => :hbox, :label_width => 125, :width => 350,
              :items => [
                { :name => :esteemed_price, :hide_label => true, :xtype => :numberfield,
                  :field_style => 'text-align: right;', :decimal_precision => 2, :decimal_separator => '.',
                  :width => 100 },
                { :name => :le_currency__display_symbol,    :hide_label => true, :width => 40, :margin => '0 0 0 2',
                  :default_value => Netzke::Core.current_user.get_default_currency_id_from_firm() },
              ]
            },
            {
              :xtype => :fieldset, :title => I18n.t(:status),
              :layout => :hbox, :width => 335, :defaults => {:margin => '0 10 2 0'},
              :items => [
                { :name => :has_gone_gold, :hide_label => true, :box_label => I18n.t(:has_gone_gold),
                  :default_value => false, :unchecked_value => 'false'
                },
                { :name => :is_closed,     :hide_label => true, :box_label => I18n.t(:is_closed),
                  :default_value => false, :unchecked_value => 'false'
                },
                { :name => :has_been_invoiced, :hide_label => true, :box_label => I18n.t(:has_been_invoiced),
                  :default_value => false, :unchecked_value => 'false'
                },
                { :name => :is_a_demo,     :hide_label => true, :box_label => I18n.t(:is_a_demo),
                  :default_value => false, :unchecked_value => 'false'
                }
              ]
            }
          ]
        }
      ]
    },
    {
      :layout => :column, :border => false, :column_width => 1.0,
      :items => [
        { :name => :description, :field_label => I18n.t(:description), :height => 40, :width => 800,
          :margin => '2 0 2 0'
        },
        { :name => :notes,       :field_label => I18n.t(:notes), :height => 60, :width => 800,
          :margin => '2 0 2 0'
        }
      ]
    }
  ]

  # ---------------------------------------------------------------------------
end
