#
# Specialized list/grid component implementation with filtering support
# in a dedicated header which interacts directly with the scoping of the data grid.
#
# - author: Steve A.
# - vers. : 3.03.15.20130422
#
# == Params
#
# :+record_id+ must be set during component configuration and must point to the current header's Project.id
#
class FilteredAccountManagePanel < Netzke::Basepack::BorderLayoutPanel

  js_properties(
    :prevent_header => true,
    :header => false,
    :border => true
  )


  def configuration
    super.merge(
      :persistence => true,
      :min_width => 800,
      :items => [
        :account_header.component( :region => :north ),
        :filtering_header.component( :region => :center ),
        :list_view_grid.component( :region => :south )
      ]
    )
  end
  # ---------------------------------------------------------------------------

  MANAGE_HEADER_HEIGHT = 94                         # this is referenced also more below


  component :account_header do
    {
      :class_name => "Netzke::Basepack::FormPanel",
      :model => 'Account',
      :mode => :lockable,
      :record_id => config[:record_id],
      # [20120221] This field is required by model, but we are silently filtering by the firm, so we use
      # a strong default to enforce its value:
      :strong_default_attrs => {
          :firm_id => Netzke::Core.current_user.firm_id
      },
      :prevent_header => true,
      :height => MANAGE_HEADER_HEIGHT,
      :items => [
        {
          :layout => :column, :border => false,
          :items => [
            {
              :column_width => 1.00, :border => false, :defaults => { :label_width => 80 },
              :items => [
                {
                  :xtype => :fieldcontainer, :field_label => I18n.t(:created_slash_updated_on),
                  :layout => :hbox, :label_width => 125, :width => 400,
                  :items => [
                    { :name => :created_on,    :hide_label => true, :xtype => :displayfield, :width => 120},
                    { :xtype => :displayfield, :value => ' / ',     :margin => '0 2 0 2' },
                    { :name => :updated_on,    :hide_label => true, :xtype => :displayfield, :width => 120 }
                  ]
                },
                {
                  :xtype => :fieldcontainer, :field_label => I18n.t(:name),
                  :layout => :hbox, :label_width => 125, :width => 800,
                  :items => [
                    { :name => :name, :hide_label => true, :width => 150, :field_style => 'font-size: 110%; font-weight: bold;' },
                    { :xtype => :displayfield, :value => ' ', :margin => '0 4 0 4' },
                    { :name => :description, :field_label => I18n.t(:description), :width => 500 }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  end
  # ---------------------------------------------------------------------------


  component :filtering_header do
    {
      :class_name => "FilteringDateRangePanel",
      :filtering_date_start => component_session[:filtering_date_start] ||= config[:filtering_date_start],
      :filtering_date_end   => component_session[:filtering_date_end] ||= config[:filtering_date_end],
      :show_current_user_firm => true
    }
  end
  # ---------------------------------------------------------------------------


  # Endpoint for refreshing the "global" data scope of the grid on the server-side component
  # (simply by updating the component session field used as variable parameter).
  #
  # == Params (either are facultative)
  # - filtering_date_start : an ISO-formatted (Y-m-d) date with which the grid scope can be updated
  # - filtering_date_end : as above, but for the ending-date of the range
  #
  endpoint :update_filtering_scope do |params|
#    logger.debug( "--- update_filtering_scope: #{params.inspect}" )

    # [Steve, 20120221] Since the component_session returns a member of the component and not
    # a constant value, is treated by the config hash as a reference, thus it suffices to update
    # its value to see it also updated inside the component config structure itself.
    component_session[:filtering_date_start] = params[:filtering_date_start] if params[:filtering_date_start]
    component_session[:filtering_date_end]   = params[:filtering_date_end] if params[:filtering_date_end]

    # [Steve, 20120221 - DONE] The following can be replaced (totally, with no return hash) by a
    # single JS call:
    #
    #           this.getComponent('filtering_header').getStore().load();
    #
    # ...placed just after each this.updateFilteringScope(...) call inside the event listeners.
    #
    # Keep in mind that invoking the loadStoreData() server-side won't trigger the loading mask
    # automatically on the UI (instead the above JS command does everything in one).
    #
    # But for sake of clarity and to illustrate how to do it server-side, here it is anyway:
    #
                                                    # Rebuild server-side the data of the grid
#    cmp_grid = component_instance( :list_view_grid )
#    cmp_data = cmp_grid.get_data
                                                    # The following will the invoke Ext.data.Store.loadData on the client-side:
#    {
#      :list_view_grid => { :load_store_data => cmp_data }
#    }
  end
  # ---------------------------------------------------------------------------


  component :list_view_grid do
    {
      :class_name => "AccountRowsGrid",
      # [20130422] Do NOT use a lambda with a sort clause here on the scope, since it will prevent ordering
      # by column-click to work.
      # To actually use a lambda yielding a Relation parameter, the scope definition should be moved
      # inside the component config definition, since using lambda here will yield a Proc parameter instead. 
      # It doesn't work if declared from the view, since the Proc object passed to the :scope
      # is not the actual ActiveRecord::Relation from the data provider.
      :scope => [
        "account_id = ? AND ( (DATE_FORMAT(date_entry,'#{AGEX_FILTER_DATE_FORMAT_SQL}') >= ? AND DATE_FORMAT(date_entry,'#{AGEX_FILTER_DATE_FORMAT_SQL}') <= ?) OR date_entry IS NULL )",
        config[:record_id],
        component_session[:filtering_date_start] ||= config[:filtering_date_start],
        component_session[:filtering_date_end] ||= config[:filtering_date_end]
      ],

      :strong_default_attrs => {
        :account_id => config[:record_id]
      },

      :account_id => config[:record_id],
      :default_currency_id => config[:default_currency_id],
      :height => config[:height] - MANAGE_HEADER_HEIGHT - FilteringDateRangePanel::FILTERING_PANEL_DEFAULT_HEIGHT
    }
  end
  # ---------------------------------------------------------------------------
end
