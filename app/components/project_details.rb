#
# Specialized Project details form component implementation
#
# - author: Steve A.
# - vers. : 3.04.05.20130628
#
class ProjectDetails < Netzke::Basepack::FormPanel

  model 'Project'

  js_properties(
    :prevent_header => true,
    :border => false
  )


  def configuration
   super.merge(
     :min_width => 850,
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
            { :name => :project__codename,  :field_label => I18n.t(:project__codename),
              # [20121121] For the combo-boxes to have a working query after the 4th char is entered in the edit widget,
              # a lambda statement must be used. Using a pre-computed scope from the Model class prevents Netzke
              # (as of this version) to append the correct WHERE clause to the scope itself (with an inline lambda, instead, it works).
              :scope => lambda { |rel| rel.order("codename ASC") }
            },
            # [Steve, 20120201] (scope definitions can be found inside the Firm model)
            { :name => :firm__get_full_name, :field_label => I18n.t(:developer_firm),
              :width => 400,
              # [20121121] See note above for the sorted combo boxes.
              :scope => lambda {|rel| rel.house_firms.still_available.order("name ASC")},
              :default_value => Netzke::Core.current_user.firm_id },
            { :name => :partner_firm__get_full_name,    :field_label => I18n.t(:partner_firm__get_full_name),
              :width => 400,
              # [20121121] See note above for the sorted combo boxes.
              :scope => lambda {|rel| rel.partners.still_available.order("name ASC")}
            },
            { :name => :committer_firm__get_full_name,  :field_label => I18n.t(:committer_firm__get_full_name),
              :width => 400,
              # [20121121] See note above for the sorted combo boxes.
              :scope => lambda {|rel| rel.committers.still_available.order("name ASC")}
            }
          ]
        },
        {
          :column_width => 0.50, :border => false,
          :items => [
            { :name => :team__name, :field_label => I18n.t(:team__name), :label_width => 125,
              :margin => '0 0 2 0', :scope => lambda { |rel|
                # [Steve, 20120201] (scope definitions can be found inside the Team model)
                # [20121121] See note above for the sorted combo boxes.
                rel.still_available.where(
                  ['(firm_id = ?) OR (firm_id = NULL)', Netzke::Core.current_user.firm_id]
                ).order("name ASC")
              }
            },
            {
              :xtype => :fieldcontainer, :field_label => I18n.t(:created_slash_updated_on),
              :layout => :hbox, :label_width => 125, :width => 400,
              :items => [
                { :name => :created_on,    :hide_label => true, :xtype => :displayfield, :width => 120 },
                { :xtype => :displayfield, :value => ' / ', :margin => '0 2 0 2' },
                { :name => :updated_on,    :hide_label => true, :xtype => :displayfield, :width => 120 }
              ]
            },
            {
              :xtype => :fieldcontainer, :field_label => I18n.t(:activity_start_end),
              :layout => :hbox, :label_width => 125, :width => 510,
              :items => [
                { :name => :date_start, :hide_label => true, :format => 'Y-m-d', :width => 180,
                  :default_value => DateTime.now },
                { :xtype => :displayfield,      :value => '...', :margin => '0 2 0 2' },
                { :name => :date_end,   :hide_label => true, :format => 'Y-m-d', :width => 180 }
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
                  # [20121121] See note above for the sorted combo boxes.
                  :scope => lambda { |rel| rel.order("display_symbol ASC") },
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

0  # ---------------------------------------------------------------------------
end
