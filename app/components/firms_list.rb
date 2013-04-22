#
# Specialized Firms list/grid component implementation
#
# - author: Steve A.
# - vers. : 3.03.14.20130419
#
class FirmsList < Netzke::Basepack::GridPanel

  action :row_counter, :text => I18n.t(:click_on_the_grid), :disabled => true
  # ---------------------------------------------------------------------------


  model 'Firm'

  js_properties(
    :prevent_header => true,
    # FIXME The Netzke endpoint, once configured, ignores any subsequent request to turn off or resize the pagination
    # TODO Either wait for a new Netzke release that changes this behavior, or rewrite from scratch the endpoint implementation for the service of grid data retrieval
    :enable_pagination => false,
    :features => [{ :ftype => 'summary' }],
#    :prohibit_update => true,
#    :prohibit_delete => true,
    :border => false
  )


  add_form_config :class_name => "FirmDetails"
  add_form_window_config :height => 600, :width => 450, :title => "#{I18n.t(:add_firm)}"

  edit_form_config :class_name => "FirmDetails"
  edit_form_window_config :height => 600, :width => 450, :title => "#{I18n.t(:edit_firm)}"


  def configuration
    # ASSERT: assuming current_user is always set for this grid component:
    super.merge(
      :persistence => true,
      :columns => [
        { :name => :get_verbose_name, :label => I18n.t(:name), :flex => 1, :read_only => true,
          :sorting_scope => :sort_firm_by_verbose_name, :summary_type => :count
        },
        { :name => :is_user, :label => I18n.t(:is_user), :read_only => true },
        { :name => :is_committer, :label => I18n.t(:is_committer), :read_only => true },
        { :name => :is_partner, :label => I18n.t(:is_partner), :read_only => true },
        { :name => :is_vendor, :label => I18n.t(:is_vendor), :read_only => true },
        { :name => :is_out_of_business, :label => I18n.t(:is_out_of_business),
          :read_only => true
        }
      ]
    )
  end


  # Top bar with custom actions
  #
  js_property :tbar, [
     :search.action,
     "-",                                           # Adds a separator
     :del.action,
     "-",
     :add_in_form.action,
     :edit_in_form.action
  ]


  # Override for default bottom bar:
  #
 def default_bbar
   [ :row_counter.action ]
 end


  # Override for default context menu
  #
  def default_context_menu
    [
       :row_counter.action,
       "-",
       :del.action,
       :edit_in_form.action
    ]
  end
  # ---------------------------------------------------------------------------


  js_method :init_component, <<-JS
    function(){
      // Another - more convolute way - to call superclass's initComponent:
      #{js_full_class_name}.superclass.initComponent.call(this);

      // Update in real time the state of the available actions on selection change:
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
          gridPanel.store.sort([ { property: 'get_verbose_name', direction: 'ASC' } ]);
        },
        this
      );
    }  
  JS
  # ---------------------------------------------------------------------------
end
