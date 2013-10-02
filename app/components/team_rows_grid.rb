#
# Specialized Team rows list/grid component implementation
#
# - author: Steve A.
# - vers. : 3.05.05.20131002
#
class TeamRowsGrid < Netzke::Basepack::GridPanel

  action :row_counter,  :text => I18n.t(:click_on_the_grid), :disabled => true


  model 'TeamRow'

  js_properties(
    :prevent_header => true,
    :border => false
  )


  add_form_window_config  :width => 500, :title => "#{I18n.t(:add_team_row)}"
  edit_form_window_config :width => 500, :title => "#{I18n.t(:edit_team_row)}"


  # Override for default bottom bar:
  #
  def default_bbar
    [
      :add.action, :edit.action, :apply.action, :del.action,
     "-",                                           # Adds a separator
     :search.action,
     "-",                                           # Adds a separator
     {
        :menu => [:add_in_form.action, :edit_in_form.action],
        :text => I18n.t(:edit_in_form),
        :icon => "/images/icons/application_form.png"
     },
     "-",                                           # Adds a separator
     :row_counter.action
    ]
  end


  # Override for default context menu
  #
  def default_context_menu
    [
       :row_counter.action,
       "-",                                         # Adds a separator
       *super                                       # Inherit all other commands
    ]
  end

  # ---------------------------------------------------------------------------


  def configuration
    # ASSERT: assuming current_user is always set for this grid component:
    super.merge(
      :enable_pagination => ( toggle_pagination = AppParameter.get_default_pagination_enable_for( :teams ) ),
      # [Steve, 20120914] It seems that the LIMIT parameter used during column sort can't be toggled off even when pagination is false, so we put an arbitrary 10Tera row count limit per page to get all the rows: 
      :rows_per_page => ( toggle_pagination ? AppParameter.get_default_pagination_rows_for( :teams ) : 1000000000000 ),

      :columns => [
          { :name => :human_resource__get_verbose_name,  :label => I18n.t(:human_resource),
            # [20121121] For the combo-boxes to have a working query after the 4th char is entered in the edit widget,
            # a lambda statement must be used. Using a pre-computed scope from the Model class prevents Netzke
            # (as of this version) to append the correct WHERE clause to the scope itself (with an inline lambda, instead, it works).
            :scope => lambda { |rel| rel.still_available.order("name ASC") },
            :flex => 1, :sorting_scope => :sort_team_row_by_resource
          },
          { :name => :get_is_no_more_available, :label => I18n.t(:is_no_more_available),
            :renderer => "renderNotAvailableFlag", :width => 60, :read_only => true,
            :sorting_scope => :sort_team_row_by_is_no_more_available
          }
      ]
    )
  end
  # ---------------------------------------------------------------------------


  js_method :renderNotAvailableFlag, <<-JS
    function( value ){
      if ( value == null || value == 'false' || value == 'False' || value == 'FALSE' || value == '' || value == '0' ) {
        return '';
      }
      return "<img height='14' border='0' align='top' src='/images/icons/user_delete.png' />";
    }
  JS


  js_method :init_component, <<-JS
    function(){
      #{js_full_class_name}.superclass.initComponent.call(this);

      // Update in real time the enabled state of the available actions:
      this.getSelectionModel().on(
        'selectionchange',
        function(selModel) {
          this.actions.rowCounter.setText( '#{I18n.t(:tot_rows)}: ' + this.getStore().getCount() + ' / #{I18n.t(:selected)}: ' + selModel.getCount() );
        },
        this
      );
                                                    // As soon as the grid is ready, sort it by default:
      this.on( 'viewready',
        function( gridPanel, eOpts ) {
          gridPanel.store.sort([ { property: 'human_resource__get_verbose_name', direction: 'ASC' } ]);
        },
        this
      );
    }  
  JS
  # ---------------------------------------------------------------------------
end
