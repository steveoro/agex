#
# Specialized list/grid component implementation with filtering support
# in a dedicated header which interacts directly with the scoping of the data grid.
#
# - author: Steve A.
# - vers. : 3.03.14.20130419
#
class FilteredInvoicesList < Netzke::Basepack::BorderLayoutPanel

  CTRL_MANAGE_DUMMY_TARGET = "#{Netzke::Core.controller.manage_invoice_path( :locale => I18n.locale, :id => -1 )}"

  js_properties(
    :prevent_header => true,
    :header => false,
    :border => true
  )


  def configuration
    super.merge(
      :items => [
        :filtering_header.component( :region => :north ),
        :list_view_grid.component( :region => :center )
      ]
    )
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


  js_method :init_component, <<-JS
    function(){
      #{js_full_class_name}.superclass.initComponent.call(this);
                                                    // Retrieve the data grid and set a "replaceable" destination path for the ctrl_manage action:
      var gridView = this.getComponent('list_view_grid');
      var sTarget = "#{CTRL_MANAGE_DUMMY_TARGET}";
      gridView.targetForCtrlManage = sTarget;       // This dummy target (id:-1) will be overwritten by the MacroEntityGrid implementation of ctrl_manage
    }  
  JS
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
      :class_name => "InvoicesGrid",
      :scope => [
        "firm_id = ? AND ( (DATE_FORMAT(date_invoice,'#{AGEX_FILTER_DATE_FORMAT_SQL}') >= ? AND DATE_FORMAT(date_invoice,'#{AGEX_FILTER_DATE_FORMAT_SQL}') <= ?) OR date_invoice IS NULL )",
        Netzke::Core.current_user.firm_id,
        component_session[:filtering_date_start] ||= config[:filtering_date_start],
        component_session[:filtering_date_end] ||= config[:filtering_date_end]
      ]
    }
  end
  # ---------------------------------------------------------------------------
end
