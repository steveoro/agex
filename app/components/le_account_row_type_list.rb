#
# Specialized LeAccountRowType list/grid component implementation
#
# - author: Steve A.
# - vers. : 3.05.05.20131002
#
class LeAccountRowTypeList < EntityGrid

  model 'LeAccountRowType'
  # ---------------------------------------------------------------------------


  def configuration
    super.merge(
      :prevent_header => true,
      :add_form_window_config => { :width => 500, :title => "#{I18n.t(:add)} #{I18n.t(:le_account_row_type, {:scope=>[:activerecord, :models]})}" },
      :edit_form_window_config => { :width => 500, :title => "#{I18n.t(:edit)} #{I18n.t(:le_account_row_type, {:scope=>[:activerecord, :models]})}" },
      :columns => [
        { :name => :created_on, :label => I18n.t(:created_on), :width => 80, :read_only => true,
          :format => 'Y-m-d', :summary_type => :count },
        { :name => :updated_on, :label => I18n.t(:updated_on), :width => 80, :read_only => true,
          :format => 'Y-m-d' },
        { :name => :name, :label => I18n.t(:name), :flex => 1 },
        { :name => :is_a_parent, :label => I18n.t(:is_a_parent), :qtip => I18n.t(:is_a_parent_tooltip),
          :default_value => false, :unchecked_value => 'false'
        }
      ],
    )
  end


  js_method :init_component, <<-JS
    function(){
      // Another - more convolute way - to call superclass's initComponent:
      #{js_full_class_name}.superclass.initComponent.call(this);
                                                    // As soon as the grid is ready, sort it by default:
      this.on( 'viewready',
        function( gridPanel, eOpts ) {
          gridPanel.store.sort([ { property: 'name', direction: 'ASC' } ]);
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
      { :name => :created_on, :field_label => I18n.t(:created_on), :width => 80, :read_only => true,
        :format => 'Y-m-d', :summary_type => :count },
      { :name => :updated_on, :field_label => I18n.t(:updated_on), :width => 80, :read_only => true,
        :format => 'Y-m-d' },
      { :name => :name, :field_label => I18n.t(:name), :flex => 1 },
      { :name => :is_a_parent, :field_label => I18n.t(:is_a_parent), :qtip => I18n.t(:is_a_parent_tooltip),
        :default_value => false, :unchecked_value => 'false',
        :field_style => 'min-height: 13px; padding-left: 13px;'
      }
    ]
  end
  # ---------------------------------------------------------------------------
end
