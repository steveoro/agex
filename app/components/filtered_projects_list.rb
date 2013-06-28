#
# Specialized list/grid component implementation with filtering support
# in a dedicated header which interacts directly with the scoping of the data grid.
#
# - author: Steve A.
# - vers. : 3.04.05.20130628
#
class FilteredProjectsList < Netzke::Basepack::BorderLayoutPanel

  CTRL_MANAGE_DUMMY_TARGET = "#{Netzke::Core.controller.manage_project_path( :locale => I18n.locale, :id => -1 )}"

  js_properties(
    :prevent_header => true,
    :header => false,
    :border => true
  )


  def configuration
    super.merge(
      :persistence => true,
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
      :class_name => "MacroEntityGrid",
      :model => 'Project',
      :persistence => true,

      :add_form_config => { :class_name => "ProjectDetails" },
      :add_form_window_config => { :width => 930, :title => "#{I18n.t(:add_project)}" },

      :edit_form_config => { :class_name => "ProjectDetails" },
      :edit_form_window_config => { :width => 930, :title => "#{I18n.t(:edit_project)}" },

      :scope => [
        "firm_id = ? AND DATE_FORMAT(date_start,'#{AGEX_FILTER_DATE_FORMAT_SQL}') >= ? AND (DATE_FORMAT(date_end,'#{AGEX_FILTER_DATE_FORMAT_SQL}') <= ? OR date_end IS NULL)",
        Netzke::Core.current_user.firm_id,
        component_session[:filtering_date_start] ||= config[:filtering_date_start],
        component_session[:filtering_date_end] ||= config[:filtering_date_end]
      ],
      # [20120221] This field is required by model, but we are silently filtering by the firm, so we use
      # a strong default to enforce its value:
      :strong_default_attrs => {
          :firm_id => Netzke::Core.current_user.firm_id
      },
      :columns => [
          { :name => :created_on, :label => I18n.t(:created_on), :width => 80,  :read_only => true,
            :format => 'Y-m-d', :summary_type => :count },
          { :name => :updated_on, :label => I18n.t(:updated_on), :width => 120, :read_only => true,
            :format => 'Y-m-d' },
          { :name => :codename,           :label => I18n.t(:codename) },
          { :name => :name,               :label => I18n.t(:name) },
          { :name => :project__codename,  :label => I18n.t(:project__codename),
            # [20121121] For the combo-boxes to have a working query after the 4th char is entered in the edit widget,
            # a lambda statement must be used. Using a pre-computed scope from the Model class prevents Netzke
            # (as of this version) to append the correct WHERE clause to the scope itself (with an inline lambda, instead, it works).
            :scope => lambda { |rel| rel.order("codename ASC") },
            :sorting_scope => :sort_project_by_parent },
          { :name => :date_start,         :label => I18n.t(:date_start), :width => 80,
            :format => 'Y-m-d', :default_value => DateTime.now },
          { :name => :date_end,           :label => I18n.t(:date_end),
            :format => 'Y-m-d', :width => 80 },

          { :name => :description,        :label => I18n.t(:description), :width => 200 },

          { :name => :is_closed,          :label => I18n.t(:is_closed),
            :default_value => false, :unchecked_value => 'false'
          },
          { :name => :has_gone_gold,      :label => I18n.t(:has_gone_gold),
            :default_value => false, :unchecked_value => 'false'
          },
          { :name => :has_been_invoiced,  :label => I18n.t(:has_been_invoiced),
            :default_value => false, :unchecked_value => 'false'
          },
          { :name => :is_a_demo,          :label => I18n.t(:is_a_demo),
            :default_value => false, :unchecked_value => 'false'
          },

          # [Steve, 20120221] See note above. Column filtered but kept here as reference:
#          { :name => :firm__get_full_name, :label => I18n.t(:developer_firm), :width => 100,
            # [Steve, 20120201] (scope definitions can be found inside the Firm model)
#            :scope => lambda {|rel| rel.house_firms.still_available},
#            :default_value => Netzke::Core.current_user.firm_id },

          # [Steve, 20120212] Since the following is the first "firms" table used, it will be called
          # simply "firms" in the sorting scope by ActiveRecord dynamic querying methods:
          { :name => :partner_firm__get_full_name,    :label => I18n.t(:partner_firm__get_full_name),
            :width => 100,
            :scope => lambda {|rel| rel.partners.still_available.order("name ASC")},
            :sorting_scope => :sort_project_by_firm },

          # [Steve, 20120212] The following "firms" table name inside the dynamic join will become composed
          # by the "commiter_firm" prefix by ActiveRecord, so the dedicated sorting scope is used:
          # (check out its definition inside the Project model class)
          { :name => :committer_firm__get_full_name,  :label => I18n.t(:committer_firm__get_full_name),
            :width => 100,
            :scope => lambda {|rel| rel.committers.still_available.order("name ASC")},
            :sorting_scope => :sort_project_by_committer },

          { :name => :esteemed_price,     :label => I18n.t(:esteemed_price), :width => 80,
            :xtype => 'numbercolumn', :align => 'right', :format => '0.00', :summary_type => :sum },

          # [Steve, 20120212] This column doesn't use any virtual getter like "get_full_name", thus
          # a dedicated sorting scope for this attribute shouldn'tbe necessary. But by using it, we can
          # sort also all the rows that have a null value (which would be filtered out by the join otherwise).
          { :name => :le_currency__display_symbol, :label => I18n.t(:le_currency, {:scope=>[:activerecord, :models]}), :width => 40,
            :default_value => Netzke::Core.current_user.get_default_currency_id_from_firm(),
            # [20121121] See note above for the sorted combo boxes.
            :scope => lambda { |rel| rel.order("display_symbol ASC") },
            :sorting_scope => :sort_project_by_currency },

          # [Steve, 20120212] (See note above)
          { :name => :team__name, :label => I18n.t(:team__name), :width => 100,
            # [Steve, 20120201] (scope definitions can be found inside the Team model)
            # [Steve, 20120208] This scope is quite "strict" since it does not allow to use teams owned by a partner firm, but that's ok for now...
            :scope => lambda { |rel|
              rel.still_available.where(
                ['(firm_id = ?) OR (firm_id = NULL)', Netzke::Core.current_user.firm_id]
              ).order("name ASC")
            },
            :sorting_scope => :sort_project_by_team
          },

          { :name => :notes, :label => I18n.t(:notes), :width => 200 }
      ]
    }
  end
  # ---------------------------------------------------------------------------
end
