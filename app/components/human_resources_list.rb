#
# Specialized HumanResource list/grid component implementation
#
# - author: Steve A.
# - vers. : 3.03.15.20130422
#
class HumanResourcesList < EntityGrid

  model 'HumanResource'
  # ---------------------------------------------------------------------------


  def configuration
    super.merge(
      :prevent_header => true,
      :persistence => true,

      :add_form_window_config => { :height => 600, :width => 400, :title => "#{I18n.t(:add_human_resource_row)}" },
      :edit_form_window_config => { :height => 600, :width => 400, :title => "#{I18n.t(:edit_human_resource_row)}" },

      :columns => [
    		{ :name => :contact__get_full_name, :label => I18n.t(:contact), :summary_type => :count,
    		  :sorting_scope => :sort_resource_by_contact },
    		{ :name => :le_resource_type__get_full_name, :label => I18n.t(:le_resource_type),
    		  :sorting_scope => :sort_resource_by_type },
    		{ :name => :name, :label => I18n.t(:name) },
    		{ :name => :description, :label => I18n.t(:description) },
    		{ :name => :is_no_more_available, :label => I18n.t(:is_no_more_available),
    		  :default_value => false, :unchecked_value => 'false'
    		},
    		{ :name => :le_currency__display_symbol, :label => I18n.t(:le_currency, {:scope=>[:activerecord, :models]}), :width => 40,
    		  :default_value => AppParameter.get_default_currency_id(), :sorting_scope => :sort_resource_by_currency },
    
        { :name => :cost_std_hour, :field_label => I18n.t(:cost_std_hour, {:scope=>[:project_row]}),
          :width => 80, :xtype => 'numbercolumn', :align => 'right', :format => '0.00'
        },
        { :name => :cost_ext_hour, :field_label => I18n.t(:cost_ext_hour, {:scope=>[:project_row]}),
          :width => 80, :xtype => 'numbercolumn', :align => 'right', :format => '0.00'
        },
        { :name => :cost_km, :field_label => I18n.t(:cost_km, {:scope=>[:project_row]}),
          :width => 80, :xtype => 'numbercolumn', :align => 'right', :format => '0.00'
        },
        { :name => :charge_std_hour, :field_label => I18n.t(:charge_std_hour, {:scope=>[:project_row]}),
          :width => 80, :xtype => 'numbercolumn', :align => 'right', :format => '0.00'
        },
        { :name => :charge_ext_hour, :field_label => I18n.t(:charge_ext_hour, {:scope=>[:project_row]}),
          :width => 80, :xtype => 'numbercolumn', :align => 'right', :format => '0.00'
        },
        { :name => :fixed_weekly_wage, :field_label => I18n.t(:fixed_weekly_wage, {:scope=>[:project_row]}),
          :width => 80, :xtype => 'numbercolumn', :align => 'right', :format => '0.00'
        },
        { :name => :charge_weekly_wage, :field_label => I18n.t(:charge_weekly_wage, {:scope=>[:project_row]}),
          :width => 80, :xtype => 'numbercolumn', :align => 'right', :format => '0.00'
        },
        { :name => :percentage_of_invoice, :field_label => I18n.t(:percentage_of_invoice, {:scope=>[:project_row]}),
          :width => 80, :xtype => 'numbercolumn', :align => 'right', :format => '0.00'
        },
    		{ :name => :date_start,  :label => I18n.t(:date_start), :width => 80, :default_value => DateTime.now },
    		{ :name => :notes,       :label => I18n.t(:notes), :width => 200 }
      ]
    )
  end


  js_method :init_component, <<-JS
    function(){
      // Another - more convolute way - to call superclass's initComponent:
      #{js_full_class_name}.superclass.initComponent.call(this);
                                                    // As soon as the grid is ready, sort it by default:
      this.on( 'viewready',
        function( gridPanel, eOpts ) {
          gridPanel.store.sort([ { property: 'contact__get_full_name', direction: 'ASC' } ]);
        },
        this
      );
    }  
  JS
  # ---------------------------------------------------------------------------


  # Override default fields for forms. Must return an array understood by the
  # items property of the forms.
  #
  def default_fields_for_forms
    [
		{ :name => :contact__get_full_name, :field_label => I18n.t(:contact), :summary_type => :count,
		  :sorting_scope => :sort_resource_by_contact },
		{ :name => :le_resource_type__get_full_name, :field_label => I18n.t(:le_resource_type),
		  :sorting_scope => :sort_resource_by_type },
		{ :name => :name, :field_label => I18n.t(:name) },
		{ :name => :description, :field_label => I18n.t(:description) },
		{ :name => :is_no_more_available, :field_label => I18n.t(:is_no_more_available),
		  :default_value => false, :unchecked_value => 'false'
		},
		{ :name => :le_currency__display_symbol, :field_label => I18n.t(:le_currency, {:scope=>[:activerecord, :models]}), :width => 40,
		  :default_value => AppParameter.get_default_currency_id(), :sorting_scope => :sort_resource_by_currency
		},
    { :name => :cost_std_hour, :field_label => I18n.t(:cost_std_hour, {:scope=>[:project_row]}),
      :xtype => :numberfield,
      :field_style => 'text-align: right;', :decimal_precision => 2, :decimal_separator => '.',
      :step => 0.01, :width => 100
    },
    { :name => :cost_ext_hour, :field_label => I18n.t(:cost_ext_hour, {:scope=>[:project_row]}),
      :xtype => :numberfield,
      :field_style => 'text-align: right;', :decimal_precision => 2, :decimal_separator => '.',
      :step => 0.01, :width => 100
    },
    { :name => :cost_km, :field_label => I18n.t(:cost_km, {:scope=>[:project_row]}),
      :xtype => :numberfield,
      :field_style => 'text-align: right;', :decimal_precision => 2, :decimal_separator => '.',
      :step => 0.01, :width => 100
    },
    { :name => :charge_std_hour, :field_label => I18n.t(:charge_std_hour, {:scope=>[:project_row]}),
      :xtype => :numberfield,
      :field_style => 'text-align: right;', :decimal_precision => 2, :decimal_separator => '.',
      :step => 0.01, :width => 100
    },
    { :name => :charge_ext_hour, :field_label => I18n.t(:charge_ext_hour, {:scope=>[:project_row]}),
      :xtype => :numberfield,
      :field_style => 'text-align: right;', :decimal_precision => 2, :decimal_separator => '.',
      :step => 0.01, :width => 100
    },
    { :name => :fixed_weekly_wage, :field_label => I18n.t(:fixed_weekly_wage, {:scope=>[:project_row]}),
      :xtype => :numberfield,
      :field_style => 'text-align: right;', :decimal_precision => 2, :decimal_separator => '.',
      :step => 0.01, :width => 100
    },
    { :name => :charge_weekly_wage, :field_label => I18n.t(:charge_weekly_wage, {:scope=>[:project_row]}),
      :xtype => :numberfield,
      :field_style => 'text-align: right;', :decimal_precision => 2, :decimal_separator => '.',
      :step => 0.01, :width => 100
    },
    { :name => :percentage_of_invoice, :field_label => I18n.t(:percentage_of_invoice, {:scope=>[:project_row]}),
      :xtype => :numberfield,
      :field_style => 'text-align: right;', :decimal_precision => 2, :decimal_separator => '.',
      :step => 0.01, :width => 100
    },
		{ :name => :date_start,  :field_label => I18n.t(:date_start), :width => 80, :default_value => DateTime.now },
		{ :name => :notes,       :field_label => I18n.t(:notes), :width => 200 }
    ]
  end
  # ---------------------------------------------------------------------------
end
