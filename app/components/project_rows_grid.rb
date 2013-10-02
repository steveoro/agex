#
# Specialized Project rows list/grid component implementation
#
# - author: Steve A.
# - vers. : 3.05.05.20131002
#
# == Params
#
# :+project_id+ must be set during component configuration and must point to the current header's Project.id
# :+current_team_id+ must point to the default team id set in the Project's header
# :+default_currency_id+ must point to the default currency id that has to be used
# :+default_human_resource_id+ must point to the default human resource id that has to be used
#
class ProjectRowsGrid < Netzke::Basepack::GridPanel

  action :row_counter,  :text => I18n.t(:click_on_the_grid), :disabled => true
  # ---------------------------------------------------------------------------

  action :row_list,     :text => 'Row list', :tooltip => 'TEST Row list',
                        :icon =>"/images/icons/report.png"

  action :report_pdf,   :text => I18n.t(:report_pdf, :scope =>[:project_row]),
                        :tooltip => I18n.t(:report_pdf_tooltip, :scope =>[:project_row]),
                        :icon =>"/images/icons/page_white_acrobat.png"

  action :report_odt,   :text => I18n.t(:report_odt, :scope =>[:project_row]),
                        :tooltip => I18n.t(:report_odt_tooltip, :scope =>[:project_row]),
                        :icon =>"/images/icons/page_white_word.png"

  action :report_txt,   :text => I18n.t(:report_txt, :scope =>[:project_row]),
                        :tooltip => I18n.t(:report_txt_tooltip, :scope =>[:project_row]),
                        :icon =>"/images/icons/page_white_text.png"
  # ---------------------------------------------------------------------------

  action :export_csv_full,
                        :text => I18n.t(:export_csv_full, :scope =>[:project_row]),
                        :tooltip => I18n.t(:export_csv_full_tooltip, :scope =>[:project_row]),
                        :icon =>"/images/icons/page_white_excel.png"

  action :export_csv_no_header,
                        :text => I18n.t(:export_csv_no_header, :scope =>[:project_row]),
                        :tooltip => I18n.t(:export_csv_no_header_tooltip, :scope =>[:project_row]),
                        :icon =>"/images/icons/page_white_excel.png"
  # ---------------------------------------------------------------------------

  action :add_halfday_std_devdebug,
                        :text => I18n.t(:add_halfday_std_devdebug, :scope =>[:project_row]),
                        :tooltip => I18n.t(:add_halfday_std_devdebug_tooltip, :scope =>[:project_row]),
                        :icon =>"/images/icons/clock_add.png"
  action :add_fullday_std_devdebug,
                        :text => I18n.t(:add_fullday_std_devdebug, :scope =>[:project_row]),
                        :tooltip => I18n.t(:add_fullday_std_devdebug_tooltip, :scope =>[:project_row]),
                        :icon =>"/images/icons/calendar_add.png"

  action :add_next_halfday_std_devdebug,
                        :text => I18n.t(:add_next_halfday_std_devdebug, :scope =>[:project_row]),
                        :tooltip => I18n.t(:add_next_halfday_std_devdebug_tooltip, :scope =>[:project_row]),
                        :icon =>"/images/icons/clock_add_next.png"
  action :add_next_fullday_std_devdebug,
                        :text => I18n.t(:add_next_fullday_std_devdebug, :scope =>[:project_row]),
                        :tooltip => I18n.t(:add_next_fullday_std_devdebug_tooltip, :scope =>[:project_row]),
                        :icon =>"/images/icons/calendar_add_next.png"

  action :add_fullday_ext_devdebug,
                        :text => I18n.t(:add_fullday_ext_devdebug, :scope =>[:project_row]),
                        :tooltip => I18n.t(:add_fullday_ext_devdebug_tooltip, :scope =>[:project_row]),
                        :icon =>"/images/icons/briefcase_add.png"
  # ---------------------------------------------------------------------------

  action :invoice_shown_rows,
                        :text => I18n.t(:invoice_shown_rows, :scope =>[:project_row]),
                        :tooltip => I18n.t(:invoice_shown_rows_tooltip, :scope =>[:project_row]),
                        :icon =>"/images/icons/email_open.png"

  action :invoice_shown_rows_on_partner,
                        :text => I18n.t(:invoice_shown_rows, :scope =>[:project_row]),
                        :tooltip => I18n.t(:invoice_shown_rows_tooltip, :scope =>[:project_row]),
                        :icon =>"/images/icons/email_open.png"

  action :invoice_all_rows,
                        :text => I18n.t(:invoice_all_rows, :scope =>[:project_row]),
                        :tooltip => I18n.t(:invoice_all_rows_tooltip, :scope =>[:project_row]),
                        :icon =>"/images/icons/email_open.png"

  action :invoice_all_rows_on_partner,
                        :text => I18n.t(:invoice_all_rows, :scope =>[:project_row]),
                        :tooltip => I18n.t(:invoice_all_rows_tooltip, :scope =>[:project_row]),
                        :icon =>"/images/icons/email_open.png"

  action :invoice_esteem_tot,
                        :text => I18n.t(:invoice_esteem_tot, :scope =>[:project_row]),
                        :tooltip => I18n.t(:invoice_esteem_tot_tooltip, :scope =>[:project_row]),
                        :icon =>"/images/icons/email_open.png"

  action :invoice_esteem_tot_on_partner,
                        :text => I18n.t(:invoice_esteem_tot, :scope =>[:project_row]),
                        :tooltip => I18n.t(:invoice_esteem_tot_tooltip, :scope =>[:project_row]),
                        :icon =>"/images/icons/email_open.png"
  # ---------------------------------------------------------------------------


  model 'ProjectRow'

  js_properties(
    :prevent_header => true,
    :features => [{ :ftype => 'summary' }],
    :border => false
  )


  add_form_window_config  :width => 500, :title => "#{I18n.t(:add_project_row)}"
  edit_form_window_config :width => 500, :title => "#{I18n.t(:edit_project_row)}"


  js_property :tbar, [
    {
      :menu => [
        :add_halfday_std_devdebug.action,
        :add_fullday_std_devdebug.action,
        "-",
        :add_next_halfday_std_devdebug.action,
        :add_next_fullday_std_devdebug.action,
        "-",
        :add_fullday_ext_devdebug.action
      ],
      :text => I18n.t(:add_default_row),
      :icon => "/images/icons/database_add.png"
    },
    {
      :menu => [:row_list.action, :report_pdf.action, :report_odt.action, :report_txt.action],
      :text => I18n.t(:reporting),
      :icon => "/images/icons/report.png"
    },
    {
      :menu => [:export_csv_full.action, :export_csv_no_header.action],
      :text => I18n.t(:data_export),
      :icon => "/images/icons/folder_table.png"
    },
    {
      :menu => [
        {
          :menu => [
            :invoice_shown_rows_on_partner.action,
            :invoice_all_rows_on_partner.action,
            :invoice_esteem_tot_on_partner.action
          ],
          :text => I18n.t(:recipient_partner, :scope =>[:invoice_row])
        },
        {
          :menu => [
            :invoice_shown_rows.action,
            :invoice_all_rows.action,
            :invoice_esteem_tot.action
          ],
          :text => I18n.t(:recipient_committer, :scope =>[:invoice_row])
        }
      ],
      :text => I18n.t(:invoicing),
      :icon => "/images/icons/email_open.png"
    }
  ]


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
      :persistence => true,
      # [Steve, 20120131]
      # FIXME The Netzke endpoint, once configured, ignores any subsequent request to turn off or resize the pagination
      # TODO Either wait for a new Netzke release that changes this behavior, or rewrite from scratch the endpoint implementation for the service of grid data retrieval
      :enable_pagination => ( toggle_pagination = AppParameter.get_default_pagination_enable_for( :projects ) ),
      # [Steve, 20120914] It seems that the LIMIT parameter used during column sort can't be toggled off even when pagination is false, so we put an arbitrary 10Tera row count limit per page to get all the rows: 
      :rows_per_page => ( toggle_pagination ? AppParameter.get_default_pagination_rows_for( :projects ) : 1000000000000 ),

      :min_width => 750,
      :columns => [
#          { :name => :created_on,         :label => I18n.t(:created_on), :width => 80,   :read_only => true,
#            :format => 'Y-m-d' },
#          { :name => :updated_on,         :label => I18n.t(:updated_on), :width => 120,  :read_only => true,
#            :format => 'Y-m-d' },

          { :name => :date_entry, :xtype => :datecolumn, :label => I18n.t(:date_entry, {:scope=>[:project_row]}), :width => 80,
            :format => 'Y-m-d', :summary_type => :count, :default_value => DateTime.now.strftime(AGEX_FILTER_DATE_FORMAT_SQL)
          },
          { :name => :human_resource__get_full_name,  :label => I18n.t(:human_resource__get_full_name),
            :default_value => super[:default_human_resource_id],
            # [20121121] For the combo-boxes to have a working query after the 4th char is entered in the edit widget,
            # a lambda statement must be used. Using a pre-computed scope from the Model class prevents Netzke
            # (as of this version) to append the correct WHERE clause to the scope itself (with an inline lambda, instead, it works).
            :scope => lambda { |rel|
              rel.joins(:team_rows).still_available.where( ['team_id = ?', super[:current_team_id]] ).order("name ASC")
            },
            :sorting_scope => :sort_project_row_by_resource
          },
          { :name => :std_hours,          :label => I18n.t(:std_hours, {:scope=>[:project_row]}), :width => 50, :summary_type => :sum },
          { :name => :ext_hours,          :label => I18n.t(:ext_hours, {:scope=>[:project_row]}), :width => 50, :summary_type => :sum },
          { :name => :km_tot,             :label => I18n.t(:km_tot, {:scope=>[:project_row]}), :width => 50, :summary_type => :sum },
          { :name => :extra_expenses,     :label => I18n.t(:extra_expenses, {:scope=>[:project_row]}), :width => 60, :xtype => 'numbercolumn', :align => 'right', :format => '0.00', :summary_type => :sum },
          { :name => :le_currency__display_symbol,    :label => I18n.t(:le_currency, {:scope=>[:activerecord, :models]}), :width => 40,
            :default_value => super[:default_currency_id],
            # [20121121] See note above for the sorted combo boxes.
            :scope => lambda { |rel| rel.order("display_symbol ASC") },
            :sorting_scope => :sort_project_row_by_currency
          },
          { :name => :is_analysis,        :label => I18n.t(:is_analysis, {:scope=>[:project_row]}),
            :default_value => false, :unchecked_value => 'false'
          },
          { :name => :is_development,     :label => I18n.t(:is_development, {:scope=>[:project_row]}),
            :default_value => true, :unchecked_value => 'false'
          },
          { :name => :is_deployment,      :label => I18n.t(:is_deployment, {:scope=>[:project_row]}),
            :default_value => false, :unchecked_value => 'false'
          },
          { :name => :is_debug,           :label => I18n.t(:is_debug, {:scope=>[:project_row]}),
            :default_value => true, :unchecked_value => 'false'
          },
          { :name => :is_setup,           :label => I18n.t(:is_setup, {:scope=>[:project_row]}),
            :default_value => false, :unchecked_value => 'false'
          },
          { :name => :is_study,           :label => I18n.t(:is_study, {:scope=>[:project_row]}),
            :default_value => false, :unchecked_value => 'false'
          },
          { :name => :description,        :label => I18n.t(:description), :width => 280,
            :default_value => I18n.t(:dev_debug, :scope=>[:project_row]) },
          { :name => :project_milestone__name,        :label => I18n.t(:project_milestone__name),
            # [20121121] See note above for the sorted combo boxes.
            :scope => lambda { |rel|
              rel.not_yet_implemented.where( ['project_id = ?', super[:project_id]] ).order("name ASC")
            },
            :sorting_scope => :sort_project_row_by_milestone
          },
          { :name => :notes,              :label => I18n.t(:notes), :flex => 1 }
      ]
    )
  end

  # ---------------------------------------------------------------------------


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
          gridPanel.store.sort([ { property: 'date_entry', direction: 'DESC' } ]);
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
      { :name => :date_entry, :xtype => :datecolumn, :field_label => I18n.t(:date_entry, {:scope=>[:project_row]}), :width => 80,
        :format => 'Y-m-d', :summary_type => :count, :default_value => DateTime.now.strftime(AGEX_FILTER_DATE_FORMAT_SQL)
      },
      { :name => :human_resource__get_full_name, :field_label => I18n.t(:human_resource__get_full_name),
            # [20121121] For the combo-boxes to have a working query after the 4th char is entered in the edit widget,
            # a lambda statement must be used. Using a pre-computed scope from the Model class prevents Netzke
            # (as of this version) to append the correct WHERE clause to the scope itself (with an inline lambda, instead, it works).
        :scope => lambda { |rel|
          rel.joins(:team_rows).still_available.where( ['team_id = ?', config[:current_team_id]] ).order("name ASC")
        },
        :default_value => config[:default_human_resource_id]
      },
      { :name => :std_hours,      :field_label => I18n.t(:std_hours, {:scope=>[:project_row]}), :width => 50, :summary_type => :sum },
      { :name => :ext_hours,      :field_label => I18n.t(:ext_hours, {:scope=>[:project_row]}), :width => 50, :summary_type => :sum },
      { :name => :km_tot,         :field_label => I18n.t(:km_tot, {:scope=>[:project_row]}), :width => 50, :summary_type => :sum },
      { :name => :extra_expenses, :field_label => I18n.t(:extra_expenses, {:scope=>[:project_row]}), :width => 60, :xtype => 'numbercolumn', :align => 'right', :format => '0.00', :summary_type => :sum },
      { :name => :le_currency__display_symbol, :field_label => I18n.t(:le_currency, {:scope=>[:activerecord, :models]}), :width => 40,
        :default_value => config[:default_currency_id],
        # [20121121] See note above for the sorted combo boxes.
        :scope => lambda { |rel| rel.order("display_symbol ASC") }
      },
      { :name => :is_analysis,    :field_label => I18n.t(:is_analysis, {:scope=>[:project_row]}),
        :default_value => false, :unchecked_value => 'false',
        :field_style => 'min-height: 13px; padding-left: 13px;'
      },
      { :name => :is_development, :field_label => I18n.t(:is_development, {:scope=>[:project_row]}),
        :default_value => true, :unchecked_value => 'false',
        :field_style => 'min-height: 13px; padding-left: 13px;'
      },
      { :name => :is_deployment,  :field_label => I18n.t(:is_deployment, {:scope=>[:project_row]}),
        :default_value => false, :unchecked_value => 'false',
        :field_style => 'min-height: 13px; padding-left: 13px;'
      },
      { :name => :is_debug,       :field_label => I18n.t(:is_debug, {:scope=>[:project_row]}),
        :default_value => true, :unchecked_value => 'false',
        :field_style => 'min-height: 13px; padding-left: 13px;'
      },
      { :name => :is_setup,       :field_label => I18n.t(:is_setup, {:scope=>[:project_row]}),
        :default_value => false, :unchecked_value => 'false',
        :field_style => 'min-height: 13px; padding-left: 13px;'
      },
      { :name => :is_study,       :field_label => I18n.t(:is_study, {:scope=>[:project_row]}),
        :default_value => false, :unchecked_value => 'false',
        :field_style => 'min-height: 13px; padding-left: 13px;'
      },
      { :name => :description,    :field_label => I18n.t(:description), :width => 280,
        :default_value => I18n.t(:dev_debug, :scope=>[:project_row]) },
      { :name => :project_milestone__name,  :field_label => I18n.t(:project_milestone__name),
        # [20121121] See note above for the sorted combo boxes.
        :scope => lambda { |rel|
          rel.not_yet_implemented.where( ['project_id = ?', config[:project_id]] ).order("name ASC")
        }
      },
      { :name => :notes,          :field_label => I18n.t(:notes) }
    ]
  end
  # ---------------------------------------------------------------------------


  # This is just an example of template applying directly from ExtJS, with a confirmation dialog:
  #
  js_method :on_row_list, <<-JS
    function() {
      Ext.MessageBox.confirm( this.i18n.confirmation, this.i18n.areYouSure,
        function(btn) {
          if (btn == 'yes') {
            this.doOnRowList();
          }
        },
        this
      );
    }
  JS

  # Retrieves all enlisted rows and displays them on a template, inside a dialog.
  #
  js_method :do_on_row_list, <<-JS
    function() {
      var html = "<table><tbody>";
      var tmpl = new Ext.Template("</tr><td><b>{0}</b>:</td><td>&nbsp{1}&nbsp-&nbsp{2}</td></tr>" );
      var gridStore = this.getStore();

// FIXME TEMP TEST: *********************************
      var startDt = Ext.ComponentManager.get( "#{FilteringDateRangePanel::FILTERING_DATE_START_CMP_ID}" );
      var endDt   = Ext.ComponentManager.get( "#{FilteringDateRangePanel::FILTERING_DATE_END_CMP_ID}" );
      var sDateFrom = Ext.Date.format( startDt.getValue(), "#{AGEX_FILTER_DATE_FORMAT_EXTJS}" );
      var sDateTo   = Ext.Date.format( endDt.getValue(), "#{AGEX_FILTER_DATE_FORMAT_EXTJS}" );
      alert( 'Current date range: ' + sDateFrom + ' ... ' + sDateTo );
// FIXME TEMP TEST: *********************************

      gridStore.load(
        {
          scope: this,
          // This doesn't work as expected:
//          params: { 'limit': 65535 },
          callback: function( records, operation, success ) {
            if ( success ) {
              for (i = 0; i < records.length; i++)
                if ( records[i].data != null && records[i].data != null ) {
                  html += tmpl.apply([ i, records[i].data.id, records[i].data.date_entry ]);
                }
            }

            html += "</tbody></table>";
            Ext.Msg.show({
              title: "Test Row list extraction",
              width: 400,
              msg: html
            });
            // This doesn't work as expected:
//            this.enablePagination = true;
          }
        }
      );
    }
  JS
  # ---------------------------------------------------------------------------


  # Front-end JS event handler for the action 'report_pdf'
  #
  js_method :on_report_pdf, <<-JS
    function(){
      this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.report_detail_projects_path(:type=>'pdf')}" );
    }
  JS

  # Front-end JS event handler for the action 'report_odt'
  #
  js_method :on_report_odt, <<-JS
    function(){
      this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.report_detail_projects_path(:type=>'odt')}" );
    }
  JS

  # Front-end JS event handler for the action 'report_txt'
  #
  js_method :on_report_txt, <<-JS
    function(){
      this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.report_detail_projects_path(:type=>'txt')}" );
    }
  JS

  # Front-end JS event handler for the action 'export_csv_full'
  #
  js_method :on_export_csv_full, <<-JS
    function(){
      this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.report_detail_projects_path(:type=>'full.csv')}" );
    }
  JS

  # Front-end JS event handler for the action 'export_csv_no_header'
  # [Steve, 20120306] Using 'no header' as a synonym of a single-table layout or 'flat'
  #                   (since multi-table with no-headers doesn't make much sense)
  #
  js_method :on_export_csv_no_header, <<-JS
    function(){
      this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.report_detail_projects_path(:type=>'simple.csv',:layout=>'flat')}" );
    }
  JS
  # ---------------------------------------------------------------------------


  # Front-end JS event handler for the action 'invoice_shown_rows'
  #
  js_method :on_invoice_shown_rows, <<-JS
    function() {
      Ext.MessageBox.confirm( this.i18n.confirmation, this.i18n.areYouSure,
        function(btn) {
          if (btn == 'yes') {
            this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.create_invoice_from_project_projects_path(:type=>'grouped')}" );
          }
        },
        this
      );
    }
  JS

  js_method :on_invoice_shown_rows_on_partner, <<-JS
    function() {
      Ext.MessageBox.confirm( this.i18n.confirmation, this.i18n.areYouSure,
        function(btn) {
          if (btn == 'yes') {
            this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.create_invoice_from_project_projects_path(:type=>'grouped.partner')}" );
          }
        },
        this
      );
    }
  JS

  # Front-end JS event handler for the action 'invoice_all_rows'
  #
  js_method :on_invoice_all_rows, <<-JS
    function() {
      Ext.MessageBox.confirm( this.i18n.confirmation, this.i18n.areYouSure,
        function(btn) {
          if (btn == 'yes') {
            this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.create_invoice_from_project_projects_path(:type=>'all')}" );
          }
        },
        this
      );
    }
  JS

  js_method :on_invoice_all_rows_on_partner, <<-JS
    function() {
      Ext.MessageBox.confirm( this.i18n.confirmation, this.i18n.areYouSure,
        function(btn) {
          if (btn == 'yes') {
            this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.create_invoice_from_project_projects_path(:type=>'all.partner')}" );
          }
        },
        this
      );
    }
  JS

  # Front-end JS event handler for the action 'invoice_esteem_tot'
  #
  js_method :on_invoice_esteem_tot, <<-JS
    function() {
      Ext.MessageBox.confirm( this.i18n.confirmation, this.i18n.areYouSure,
        function(btn) {
          if (btn == 'yes') {
            this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.create_invoice_from_project_projects_path(:type=>'esteem')}" );
          }
        },
        this
      );
    }
  JS

  js_method :on_invoice_esteem_tot_on_partner, <<-JS
    function() {
      Ext.MessageBox.confirm( this.i18n.confirmation, this.i18n.areYouSure,
        function(btn) {
          if (btn == 'yes') {
            this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.create_invoice_from_project_projects_path(:type=>'esteem.partner')}" );
          }
        },
        this
      );
    }
  JS
  # ---------------------------------------------------------------------------


  # Invokes a controller path sending in all the (encoded) IDs currently available on
  # the data store, together with the 'date_from_lookup' and 'date_to_lookup' parameters
  # retrieved directly from the main filtering header panel.
  # Does not add any other filters added through the search dialog.
  #
  js_method :invoke_filtered_ctrl_method, <<-JS
    function( controllerPath ) {                     // Retrieve the filtering date range:
      var startDt = Ext.ComponentManager.get( "#{FilteringDateRangePanel::FILTERING_DATE_START_CMP_ID}" );
      var endDt   = Ext.ComponentManager.get( "#{FilteringDateRangePanel::FILTERING_DATE_END_CMP_ID}" );
      var sDateFrom = Ext.Date.format( startDt.getValue(), "#{AGEX_FILTER_DATE_FORMAT_EXTJS}" );
      var sDateTo   = Ext.Date.format( endDt.getValue(), "#{AGEX_FILTER_DATE_FORMAT_EXTJS}" );
                                                    // Compose the data array with just the IDs:
      var gridStore = this.getStore();
      var rowArray = new Array();
      gridStore.each(
        function( record ) {
          rowArray.push( record.data.id );
        },
        this
      );
                                                    // If there is data, send a request:
      if ( rowArray.length > 0 ) {
        var encodedData = Ext.JSON.encode( rowArray );
                                                    // Redirect to this URL: (which performs a send_data rails command)
        location.href = controllerPath + "&data=" + encodedData + "&date_from_lookup='" + sDateFrom +
                        "'&date_to_lookup='" + sDateTo + "'";
      }
      else {
        this.netzkeFeedback( "#{I18n.t(:warning_no_data_to_send)}" );
      }
    }
  JS
  # ---------------------------------------------------------------------------
  # ---------------------------------------------------------------------------


  # Front-end JS event handler for the action 'add_halfday_std_devdebug'
  #
  js_method :on_add_halfday_std_devdebug, <<-JS
    function() {
      this.doAddDefaultRow({
          project_id: this.initialConfig.strongDefaultAttrs['projectId'],
          date_entry: new Date(),
          std_hours: 4,
          ext_hours: 0,
          description: "#{I18n.t(:dev_debug, :scope=>[:project_row])}",
          is_develop: true,
          is_debug: true
      });
    }
  JS

  # Front-end JS event handler for the action 'add_fullday_std_devdebug'
  #
  js_method :on_add_fullday_std_devdebug, <<-JS
    function() {
      this.doAddDefaultRow({
          project_id: this.initialConfig.strongDefaultAttrs['projectId'],
          date_entry: new Date(),
          std_hours: 8,
          ext_hours: 0,
          description: "#{I18n.t(:dev_debug, :scope=>[:project_row])}",
          is_develop: true,
          is_debug: true
      });
    }
  JS


  # Front-end JS event handler for the action 'add_next_halfday_std_devdebug'
  #
  js_method :on_add_next_halfday_std_devdebug, <<-JS
    function() {                                    // Retrieve last entry date in store.data:
      // [Steve, 20130417] Assuming default *descending* date column sorting is being used:
      var lastInsertedRow = this.getStore().data.first();
      var prevDate = lastInsertedRow.data.date_entry;
      if ( prevDate == null )
        prevDate = new Date();
      var nextDate = Ext.Date.add( prevDate, Ext.Date.DAY, 1 );
                                                    // Invoke the row-add:
      this.doAddDefaultRow({
          project_id: this.initialConfig.strongDefaultAttrs['projectId'],
          date_entry: nextDate,
          std_hours: 4,
          ext_hours: 0,
          description: "#{I18n.t(:dev_debug, :scope=>[:project_row])}",
          is_develop: true,
          is_debug: true
      });
    }
  JS

  # Front-end JS event handler for the action 'add_next_fullday_std_devdebug'
  #
  js_method :on_add_next_fullday_std_devdebug, <<-JS
    function(){                                     // Retrieve last entry date in store.data:
      // [Steve, 20130417] Assuming default *descending* date column sorting is being used:
      var lastInsertedRow = this.getStore().data.first();
      var prevDate = lastInsertedRow.data.date_entry;
      if ( prevDate == null )
        prevDate = new Date();
      var nextDate = Ext.Date.add( prevDate, Ext.Date.DAY, 1 );
                                                    // Invoke the row-add:
      this.doAddDefaultRow({
          project_id: this.initialConfig.strongDefaultAttrs['projectId'],
          date_entry: nextDate,
          std_hours: 8,
          ext_hours: 0,
          description: "#{I18n.t(:dev_debug, :scope=>[:project_row])}",
          is_develop: true,
          is_debug: true
      });
    }
  JS


  # Front-end JS event handler for the action 'add_fullday_ext_devdebug'
  #
  js_method :on_add_fullday_ext_devdebug, <<-JS
    function(){
      this.doAddDefaultRow({
          project_id: this.initialConfig.strongDefaultAttrs['projectId'],
          date_entry: new Date(),
          std_hours: 0,
          ext_hours: 8,
          description: "#{I18n.t(:ext_dev_debug, :scope=>[:project_row])}",
          is_develop: true,
          is_debug: true
      });
    }
  JS
  # ---------------------------------------------------------------------------


  # Back-end method for new row creation, called from the various +on_add_+XYZ JS methods.
  # The new row instance will take the specified field values.
  #
  # == Params:
  # - project_id      => parent project id for the new project_row instance
  # - date_entry      => date of the entry
  # - description     => verbose description
  # - std_hours       => hours of standard development
  # - ext_hours       => hours of 'external' development
  # - is_development  => 'false'=false, any other value (including nil) will set to true
  # - is_debug        => as above
  #
  endpoint :do_add_default_row do |params|
#    logger.debug "\r\n!! ------ in :do_add_default_row(#{params[:project_id]}, #{params[:date_entry]}, #{params[:std_hours]}, #{params[:ext_hours]}, #{params[:description]}) -----"
    project_id  = params[:project_id]
    date_entry  = params[:date_entry]
    std_hours   = params[:std_hours]
    ext_hours   = params[:ext_hours]
    description = params[:description]
    is_develop  = ( params[:is_development] == 'false' ? false : true )
    is_debug    = ( params[:is_debug] == 'false' ? false : true )

    if ( (project_id.to_i > 0) && (p = Project.find_by_id( project_id.to_i )) )
#      logger.debug "Adding new project_rows record for project_id #{project_id}..."
      if ( p.project_rows.last )
        human_resource_id = p.project_rows.last.human_resource_id
      else
        human_resource_id = p.team.human_resources.first.id
      end
      ProjectRow.create(
        :project_id => project_id,
        # [Steve, 20120913] Using Date.today gives always the wrong result (the day before)! Using DateTime.now instead:
        :created_on => DateTime.now,
        :date_entry => date_entry,
        :human_resource_id => human_resource_id,
        :le_currency_id => p.get_default_currency_id(),
        :std_hours => std_hours,
        :ext_hours => ext_hours,
        :description => description,
        :is_development => is_develop,
        :is_debug => is_debug
      )
    else
      logger.warn('do_add_default_row(): nothing to do, wrong parameters.')
    end
    { :after_do_add_default_row => true }
  end
  # ---------------------------------------------------------------------------


  # Refreshes the data set.
  #
  js_method :after_do_add_default_row, <<-JS
    function( result ) {
      if ( result ) {
        this.netzkeFeedback( "#{I18n.t(:row_added)}" );
        this.getStore().load();
      }
    }  
  JS
  # ---------------------------------------------------------------------------
  # ---------------------------------------------------------------------------
end
