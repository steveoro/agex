#
# Specialized Account rows list/grid component implementation
#
# - author: Steve A.
# - vers. : 3.04.05.20130628
#
# == Params
#
# :+account_id+ must be set during component configuration and must point to the current header's Invoice.id
# :+default_currency_id+ must point to the default currency id that has to be used
#
class AccountRowsGrid < Netzke::Basepack::GridPanel

  action :row_counter,  :text => I18n.t(:click_on_the_grid), :disabled => true

  action :report_pdf,   :text => I18n.t(:report_pdf, :scope =>[:account_row]),
                        :tooltip => I18n.t(:report_pdf_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/page_white_acrobat.png"

  action :report_odt,   :text => I18n.t(:report_odt, :scope =>[:account_row]),
                        :tooltip => I18n.t(:report_odt_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/page_white_word.png"

  action :report_txt,   :text => I18n.t(:report_txt, :scope =>[:account_row]),
                        :tooltip => I18n.t(:report_txt_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/page_white_text.png"
  action :report_txt_no_stats,
                        :text => I18n.t(:report_txt_no_stats, :scope =>[:account_row]),
                        :tooltip => I18n.t(:report_txt_no_stats_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/page_white_text.png"
  # ---------------------------------------------------------------------------

  action :export_csv,
                        :text => I18n.t(:export_csv, :scope =>[:account_row]),
                        :tooltip => I18n.t(:export_csv_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/page_white_excel.png"
  action :export_csv_no_stats,
                        :text => I18n.t(:export_csv_no_stats, :scope =>[:account_row]),
                        :tooltip => I18n.t(:export_csv_no_stats_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/page_white_excel.png"
  # ---------------------------------------------------------------------------

  action :summary_stats,
                        :text => I18n.t(:summary_stats, :scope =>[:account_row]),
                        :tooltip => I18n.t(:summary_stats_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/chart_bar.png"
  # ---------------------------------------------------------------------------

  action :add_gasoline_row,
                        :text => I18n.t(:add_gasoline_row, :scope =>[:account_row]),
                        :tooltip => I18n.t(:add_gasoline_row_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/car.png"
  action :add_library_row,
                        :text => I18n.t(:add_library_row, :scope =>[:account_row]),
                        :tooltip => I18n.t(:add_library_row_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/newspaper_add.png"
  action :add_cash_integration_row,
                        :text => I18n.t(:add_cash_integration_row, :scope =>[:account_row]),
                        :tooltip => I18n.t(:add_cash_integration_row_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/coins_add.png"

  action :add_invoice_payment_row,
                        :text => I18n.t(:add_invoice_payment_row, :scope =>[:account_row]),
                        :tooltip => I18n.t(:add_invoice_payment_roww_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/email_open.png"

  action :add_grocery_coop_row,
                        :text => I18n.t(:add_grocery_coop_row, :scope =>[:account_row]),
                        :tooltip => I18n.t(:add_grocery_coop_row_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/cart.png"
  action :add_grocery_bio_row,
                        :text => I18n.t(:add_grocery_bio_row, :scope =>[:account_row]),
                        :tooltip => I18n.t(:add_grocery_bio_row_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/cart_bio.png"
  action :add_grocery_card_bill_row,
                        :text => I18n.t(:add_grocery_card_bill_row, :scope =>[:account_row]),
                        :tooltip => I18n.t(:add_grocery_card_bill_row_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/cart.png"
  action :add_adsl_service_row,
                        :text => I18n.t(:add_adsl_service_row, :scope =>[:account_row]),
                        :tooltip => I18n.t(:add_adsl_service_row_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/connect.png"
  action :add_telephone_row,
                        :text => I18n.t(:add_telephone_row, :scope =>[:account_row]),
                        :tooltip => I18n.t(:add_telephone_row_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/telephone.png"
  action :add_electricity_service_row,
                        :text => I18n.t(:add_electricity_service_row, :scope =>[:account_row]),
                        :tooltip => I18n.t(:add_electricity_service_row_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/lightbulb.png"
  action :add_electricity_service2_row,
                        :text => I18n.t(:add_electricity_service2_row, :scope =>[:account_row]),
                        :tooltip => I18n.t(:add_electricity_service2_row_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/lightbulb.png"
  action :add_trash_disposal_row,
                        :text => I18n.t(:add_trash_disposal_row, :scope =>[:account_row]),
                        :tooltip => I18n.t(:add_trash_disposal_row_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/bin.png"
  action :add_water_utility_row,
                        :text => I18n.t(:add_water_utility_row, :scope =>[:account_row]),
                        :tooltip => I18n.t(:add_water_utility_row_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/water.png"
  action :add_methane_utility_row,
                        :text => I18n.t(:add_methane_utility_row, :scope =>[:account_row]),
                        :tooltip => I18n.t(:add_methane_utility_row_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/fire.png"
  action :add_dinner_out_row,
                        :text => I18n.t(:add_dinner_out_row, :scope =>[:account_row]),
                        :tooltip => I18n.t(:add_dinner_out_row_tooltip, :scope =>[:account_row]),
                        :icon =>"/images/icons/drink.png"
  # ---------------------------------------------------------------------------

  model 'AccountRow'

  js_properties(
    :prevent_header => true,
    :features => [{ :ftype => 'summary' }],
    :border => false
  )


  add_form_window_config  :width => 500, :title => "#{I18n.t(:add_account_row)}"
  edit_form_window_config :width => 500, :title => "#{I18n.t(:edit_account_row)}"


  js_property :tbar, [
    {
      :menu => [
        :add_gasoline_row.action,
        :add_library_row.action,
        :add_cash_integration_row.action,
        "-",
        :add_invoice_payment_row.action,
        "-",
        :add_grocery_coop_row.action,
        :add_grocery_bio_row.action,
        :add_grocery_card_bill_row.action,
        :add_adsl_service_row.action,
        :add_telephone_row.action,
        :add_electricity_service_row.action,
        :add_electricity_service2_row.action,
        :add_trash_disposal_row.action,
        :add_water_utility_row.action,
        :add_methane_utility_row.action,
        :add_dinner_out_row.action
      ],
      :text => I18n.t(:add_default_row),
      :icon => "/images/icons/database_add.png"
    },
    {
      :menu => [:report_pdf.action, :report_odt.action, :report_txt.action, :report_txt_no_stats.action],
      :text => I18n.t(:reporting),
      :icon => "/images/icons/report.png"
    },
    {
      :menu => [:export_csv.action, :export_csv_no_stats.action],
      :text => I18n.t(:data_export),
      :icon => "/images/icons/folder_table.png"
    },
    :summary_stats.action
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
      # TODO Either wait for a new Netzke release that changes this behaviour, or rewrite from scratch the endpoint implementation for the service of grid data retrieval
      :enable_pagination => false,
      # [Steve, 20120914] It seems that the LIMIT parameter used during column sort can't be toggled off, so we put an arbitrary 10Tera row count limit per page to get all the rows: 
      :rows_per_page => 1000000000000,
      :min_width => 750,
      :columns => [
#          { :name => :created_on, :label => I18n.t(:created_on), :width => 80,   :read_only => true,
#            :format => 'Y-m-d' },
#          { :name => :updated_on, :label => I18n.t(:updated_on), :width => 120,  :read_only => true,
#            :format => 'Y-m-d' },

          { :name => :user__name, :label => I18n.t(:user), :width => 70, :default_value => Netzke::Core.current_user.id,
            # [20121121] For the combo-boxes to have a working query after the 4th char is entered in the edit widget,
            # a lambda statement must be used. Using a pre-computed scope from the Model class prevents Netzke
            # (as of this version) to append the correct WHERE clause to the scope itself (with an inline lambda, instead, it works).
            :scope => lambda { |rel| rel.order("name ASC") },
            :sorting_scope => :sort_account_row_by_user
          },
          { :name => :date_entry, :label => I18n.t(:date_entry, {:scope=>[:account_row]}), :width => 80,
            :format => 'Y-m-d', :default_value => DateTime.now, :summary_type => :count
          },

          { :name => :entry_value,     :label => I18n.t(:entry_value, {:scope=>[:account_row]}),
            :width => 60, :summary_type => :sum,
            :xtype => 'numbercolumn', :align => 'right', :format => '0.00'
          },
          { :name => :le_currency__display_symbol,    :label => I18n.t(:le_currency, {:scope=>[:activerecord, :models]}), :width => 40,
            # [20121121] See note above for the sorted combo boxes.
            :scope => lambda { |rel| rel.order("display_symbol ASC") },
            :default_value => super[:default_currency_id], :sorting_scope => :sort_account_row_by_currency
          },
          { :name => :description, :label => I18n.t(:description), :width => 280 },

          { :name => :recipient_firm__get_full_name, :label => I18n.t(:recipient_firm__get_full_name, {:scope=>[:account_row]}),
            # [20121121] See note above for the sorted combo boxes.
            :scope => lambda { |rel| rel.where(:is_out_of_business => false).order("name ASC, address ASC") },
            # This will use predefined scope for filtering, but will not sort the list entries:
            # :scope => :still_available, 
            :sorting_scope => :sort_account_row_by_firm
          },
          { :name => :parent_le_account_row_type__get_full_name, :label => I18n.t(:parent_le_account_row_type__get_full_name, {:scope=>[:account_row]}),
            # [20121121] See note above for the sorted combo boxes.
            :scope => lambda { |rel| rel.where(:is_a_parent => true).order("name ASC") },
            :sorting_scope => :sort_account_row_by_parent_type
          },
          { :name => :le_account_row_type__get_full_name, :label => I18n.t(:le_account_row_type__get_full_name, {:scope=>[:account_row]}),
            # [20121121] See note above for the sorted combo boxes.
            :scope => lambda { |rel| rel.where(:is_a_parent => false).order("name ASC") },
            :sorting_scope => :sort_account_row_by_type
          },
          { :name => :le_account_payment_type__get_full_name, :label => I18n.t(:le_account_payment_type__get_full_name, {:scope=>[:account_row]}),
            # [20121121] See note above for the sorted combo boxes.
            :scope => lambda { |rel| rel.order("name ASC") },
            :sorting_scope => :sort_account_row_by_payment_type
          },
          { :name => :check_number, :label => I18n.t(:check_number, {:scope=>[:account_row]}) },
          { :name => :notes, :label => I18n.t(:notes), :flex => 1 }
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


  # Front-end JS event handler for the action 'report_pdf'
  #
  js_method :on_report_pdf, <<-JS
    function(){
      this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.report_detail_accounts_path(:type=>'pdf')}" );
    }
  JS

  # Front-end JS event handler for the action 'report_odt'
  #
  js_method :on_report_odt, <<-JS
    function(){
      this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.report_detail_accounts_path(:type=>'odt')}" );
    }
  JS

  # Front-end JS event handler for the action 'report_txt'
  #
  js_method :on_report_txt, <<-JS
    function(){
      this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.report_detail_accounts_path(:type=>'txt')}" );
    }
  JS

  # Front-end JS event handler for the action 'report_txt_no_stats'
  #
  js_method :on_report_txt_no_stats, <<-JS
    function(){
      this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.report_detail_accounts_path(:type=>'txt', :layout=>'no_stats')}" );
    }
  JS

  # Front-end JS event handler for the action 'export_csv'
  #
  js_method :on_export_csv, <<-JS
    function(){
      this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.report_detail_accounts_path(:type=>'csv')}" );
    }
  JS

  # Front-end JS event handler for the action 'export_csv_no_stats'
  #
  js_method :on_export_csv_no_stats, <<-JS
    function(){
      this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.report_detail_accounts_path(:type=>'csv', :layout=>'no_stats')}" );
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


  # Front-end JS event handler for the action <tt>add_gasoline_row</tt>
  #
  js_method :on_add_gasoline_row, <<-JS
    function() {
      this.doAddDefaultRow({
          account_id: this.initialConfig.strongDefaultAttrs['accountId'],
          entry_value: -50,
          description: "#{I18n.t(:add_gasoline_row_desc, :scope=>[:account_row])}",
          parent_le_account_row_type_id: #{LeAccountRowType::ID_FOR_COSTS},
          le_account_row_type_id: #{LeAccountRowType::ID_FOR_GASOLINE},
          le_account_payment_type_id: #{LeAccountPaymentType::ID_FOR_CASH} 
      });
    }
  JS

  # Front-end JS event handler for the action <tt>add_library_row</tt>
  #
  js_method :on_add_library_row, <<-JS
    function() {
      this.doAddDefaultRow({
          account_id: this.initialConfig.strongDefaultAttrs['accountId'],
          entry_value: -15,
          description: "#{I18n.t(:add_library_row_desc, :scope=>[:account_row])}",
          parent_le_account_row_type_id: #{LeAccountRowType::ID_FOR_COSTS},
          le_account_row_type_id: #{LeAccountRowType::ID_FOR_LIBRARY},
          le_account_payment_type_id: #{LeAccountPaymentType::ID_FOR_CASH} 
      });
    }
  JS

  # Front-end JS event handler for the action <tt>add_cash_integration_row</tt>
  #
  js_method :on_add_cash_integration_row, <<-JS
    function() {
      this.doAddDefaultRow({
          account_id: this.initialConfig.strongDefaultAttrs['accountId'],
          entry_value: 250,
          description: "#{I18n.t(:add_cash_integration_row_desc, :scope=>[:account_row])}",
          parent_le_account_row_type_id: #{LeAccountRowType::ID_FOR_CASH_DEPOSIT},
          le_account_row_type_id: #{LeAccountRowType::ID_FOR_CASH_LOAN_BY_OWNER},
          le_account_payment_type_id: #{LeAccountPaymentType::ID_FOR_CASH} 
      });
    }
  JS
  # ---------------------------------------------------------------------------

  # Front-end JS event handler for the action <tt>add_invoice_payment_row</tt>
  #
  js_method :on_add_invoice_payment_row, <<-JS
    function() {
      this.doAddDefaultRow({
          account_id: this.initialConfig.strongDefaultAttrs['accountId'],
          entry_value: 1000,
          description: "#{I18n.t(:add_invoice_payment_row_desc, :scope=>[:account_row])}",
          parent_le_account_row_type_id: #{LeAccountRowType::ID_FOR_PROFITS},
          le_account_row_type_id: #{LeAccountRowType::ID_FOR_INVOICING},
          le_account_payment_type_id: #{LeAccountPaymentType::ID_FOR_MONEY_TRASFER} 
      });
    }
  JS
  # ---------------------------------------------------------------------------

  # Front-end JS event handler for the action <tt>add_grocery_coop_row</tt>
  #
  js_method :on_add_grocery_coop_row, <<-JS
    function() {
      this.doAddDefaultRow({
          account_id: this.initialConfig.strongDefaultAttrs['accountId'],
          entry_value: -100,
          description: "#{I18n.t(:add_grocery_coop_row_desc, :scope=>[:account_row])}",
          parent_le_account_row_type_id: #{LeAccountRowType::ID_FOR_COSTS},
          le_account_row_type_id: #{LeAccountRowType::ID_FOR_GROCERIES},
          le_account_payment_type_id: #{LeAccountPaymentType::ID_FOR_DEBIT_CARD} 
      });
    }
  JS

  # Front-end JS event handler for the action <tt>add_grocery_bio_row</tt>
  #
  js_method :on_add_grocery_bio_row, <<-JS
    function() {
      this.doAddDefaultRow({
          account_id: this.initialConfig.strongDefaultAttrs['accountId'],
          entry_value: -120,
          description: "#{I18n.t(:add_grocery_bio_row_desc, :scope=>[:account_row])}",
          parent_le_account_row_type_id: #{LeAccountRowType::ID_FOR_COSTS},
          le_account_row_type_id: #{LeAccountRowType::ID_FOR_BIO_GROCERIES},
          le_account_payment_type_id: #{LeAccountPaymentType::ID_FOR_DEBIT_CARD} 
      });
    }
  JS

  # Front-end JS event handler for the action <tt>add_adsl_service_row</tt>
  #
  js_method :on_add_adsl_service_row, <<-JS
    function() {
      this.doAddDefaultRow({
          account_id: this.initialConfig.strongDefaultAttrs['accountId'],
          entry_value: -39.90,
          description: "#{I18n.t(:add_adsl_service_row_desc, :scope=>[:account_row])}",
          parent_le_account_row_type_id: #{LeAccountRowType::ID_FOR_COSTS},
          le_account_row_type_id: #{LeAccountRowType::ID_FOR_XDSL_SERVICES},
          le_account_payment_type_id: #{LeAccountPaymentType::ID_FOR_ACCOUNT_DEBIT} 
      });
    }
  JS

  # Front-end JS event handler for the action <tt>add_telephone_row</tt>
  #
  js_method :on_add_telephone_row, <<-JS
    function() {
      this.doAddDefaultRow({
          account_id: this.initialConfig.strongDefaultAttrs['accountId'],
          entry_value: -41.50,
          description: "#{I18n.t(:add_telephone_row_desc, :scope=>[:account_row])}",
          parent_le_account_row_type_id: #{LeAccountRowType::ID_FOR_COSTS},
          le_account_row_type_id: #{LeAccountRowType::ID_FOR_COMMODITY_SERVICES},
          le_account_payment_type_id: #{LeAccountPaymentType::ID_FOR_ACCOUNT_DEBIT} 
      });
    }
  JS

  # Front-end JS event handler for the action <tt>add_electricity_service_row</tt>
  #
  js_method :on_add_electricity_service_row, <<-JS
    function() {
      this.doAddDefaultRow({
          account_id: this.initialConfig.strongDefaultAttrs['accountId'],
          entry_value: -70,
          description: "#{I18n.t(:add_electricity_service_row_desc, :scope=>[:account_row])}",
          parent_le_account_row_type_id: #{LeAccountRowType::ID_FOR_COSTS},
          le_account_row_type_id: #{LeAccountRowType::ID_FOR_COMMODITY_SERVICES},
          le_account_payment_type_id: #{LeAccountPaymentType::ID_FOR_ACCOUNT_DEBIT} 
      });
    }
  JS

  # Front-end JS event handler for the action <tt>add_electricity_service2_row</tt>
  #
  js_method :on_add_electricity_service2_row, <<-JS
    function() {
      this.doAddDefaultRow({
          account_id: this.initialConfig.strongDefaultAttrs['accountId'],
          entry_value: -70,
          description: "#{I18n.t(:add_electricity_service2_row_desc, :scope=>[:account_row])}",
          parent_le_account_row_type_id: #{LeAccountRowType::ID_FOR_COSTS},
          le_account_row_type_id: #{LeAccountRowType::ID_FOR_COMMODITY_SERVICES},
          le_account_payment_type_id: #{LeAccountPaymentType::ID_FOR_ACCOUNT_DEBIT} 
      });
    }
  JS

  # Front-end JS event handler for the action <tt>add_dinner_out_row</tt>
  #
  js_method :on_add_dinner_out_row, <<-JS
    function() {
      this.doAddDefaultRow({
          account_id: this.initialConfig.strongDefaultAttrs['accountId'],
          entry_value: -80,
          description: "#{I18n.t(:add_dinner_out_row_desc, :scope=>[:account_row])}",
          parent_le_account_row_type_id: #{LeAccountRowType::ID_FOR_COSTS},
          le_account_row_type_id: #{LeAccountRowType::ID_FOR_LUNCH_DINNER_OUT},
          le_account_payment_type_id: #{LeAccountPaymentType::ID_FOR_DEBIT_CARD} 
      });
    }
  JS

  # Front-end JS event handler for the action <tt>add_trash_disposal_row</tt>
  #
  js_method :on_add_trash_disposal_row, <<-JS
    function() {
      this.doAddDefaultRow({
          account_id: this.initialConfig.strongDefaultAttrs['accountId'],
          entry_value: -150,
          description: "#{I18n.t(:add_trash_disposal_row_desc, :scope=>[:account_row])}",
          parent_le_account_row_type_id: #{LeAccountRowType::ID_FOR_COSTS},
          le_account_row_type_id: #{LeAccountRowType::ID_FOR_COMMODITY_SERVICES},
          le_account_payment_type_id: #{LeAccountPaymentType::ID_FOR_ACCOUNT_DEBIT} 
      });
    }
  JS

  # Front-end JS event handler for the action <tt>add_water_utility_row</tt>
  #
  js_method :on_add_water_utility_row, <<-JS
    function() {
      this.doAddDefaultRow({
          account_id: this.initialConfig.strongDefaultAttrs['accountId'],
          entry_value: -150,
          description: "#{I18n.t(:add_water_utility_row_desc, :scope=>[:account_row])}",
          parent_le_account_row_type_id: #{LeAccountRowType::ID_FOR_COSTS},
          le_account_row_type_id: #{LeAccountRowType::ID_FOR_COMMODITY_SERVICES},
          le_account_payment_type_id: #{LeAccountPaymentType::ID_FOR_ACCOUNT_DEBIT} 
      });
    }
  JS

  # Front-end JS event handler for the action <tt>add_methane_utility_row</tt>
  #
  js_method :on_add_methane_utility_row, <<-JS
    function() {
      this.doAddDefaultRow({
          account_id: this.initialConfig.strongDefaultAttrs['accountId'],
          entry_value: -150,
          description: "#{I18n.t(:add_methane_utility_row_desc, :scope=>[:account_row])}",
          parent_le_account_row_type_id: #{LeAccountRowType::ID_FOR_COSTS},
          le_account_row_type_id: #{LeAccountRowType::ID_FOR_COMMODITY_SERVICES},
          le_account_payment_type_id: #{LeAccountPaymentType::ID_FOR_ACCOUNT_DEBIT} 
      });
    }
  JS

  # Front-end JS event handler for the action <tt>add_grocery_card_bill_row</tt>
  #
  js_method :on_add_grocery_card_bill_row, <<-JS
    function() {
      this.doAddDefaultRow({
          account_id: this.initialConfig.strongDefaultAttrs['accountId'],
          entry_value: -100,
          description: "#{I18n.t(:add_grocery_card_bill_row_desc, :scope=>[:account_row])}",
          parent_le_account_row_type_id: #{LeAccountRowType::ID_FOR_COSTS},
          le_account_row_type_id: #{LeAccountRowType::ID_FOR_GROCERIES},
          le_account_payment_type_id: #{LeAccountPaymentType::ID_FOR_ACCOUNT_DEBIT} 
      });
    }
  JS
  # ---------------------------------------------------------------------------


  # Back-end method for new row creation, called from the various +on_add_+XYZ JS methods.
  # The new row instance will take the specified field values.
  #
  # == Params:
  # - account_id: parent account id for the new account_row instance
  # - entry_value
  # - description
  # - parent_le_account_row_type_id
  # - le_account_row_type_id
  # - le_account_payment_type_id
  #
  endpoint :do_add_default_row do |params|
#    logger.debug "\r\n!! ------ in :do_add_default_row(#{params[:account_id]}, #{params[:entry_value]}, #{params[:description]}, #{params[:parent_le_account_row_type_id]}, #{params[:le_account_row_type_id]}, #{params[:le_account_payment_type_id]}) -----"
    account_id = params[:account_id]
    entry_value = params[:entry_value]
    description = params[:description]
    parent_le_account_row_type_id = params[:parent_le_account_row_type_id]
    le_account_row_type_id        = params[:le_account_row_type_id]
    le_account_payment_type_id    = params[:le_account_payment_type_id]

    if ( account_id.to_i > 0 )
#      logger.debug "Adding new account_rows record for account_id #{account_id}..."
      AccountRow.create(
        :account_id => account_id,
        :user_id => Netzke::Core.current_user.id,
        # [Steve, 20120913] Using Date.today gives always the wrong result (the day before)! Using DateTime.now instead:
        :date_entry => DateTime.now,
        :entry_value => entry_value,
        :le_currency_id => Netzke::Core.current_user.get_default_currency_id_from_firm(),
        :description => description,
        :parent_le_account_row_type_id => parent_le_account_row_type_id,
        :le_account_row_type_id => le_account_row_type_id,
        :le_account_payment_type_id => le_account_payment_type_id
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


  # Front-end JS event handler for the action 'summary_stats'
  #
  js_method :on_summary_stats, <<-JS
    function() {
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
        this.prepareSummaryPage({
            data: encodedData,
            date_from_lookup: sDateFrom,
            date_to_lookup: sDateTo 
        });
      }
      else {
        this.netzkeFeedback( "#{I18n.t(:warning_no_data_to_send)}" );
      }
    }
  JS
  # ---------------------------------------------------------------------------


  # Prepares the hash of data that will be used for summary page.
  #
  # === Parameters:
  # - <tt>:data</tt> (*required*) => a JSON-encoded array of AccountRow IDs to be retrieved and processed
  #
  # - <tt>:date_from_lookup</tt> => filtering date range start
  #
  # - <tt>:date_to_lookup</tt> => filtering date range end
  #
  endpoint :prepare_summary_page do |params|
    id_list = ActiveSupport::JSON.decode( params[:data] ) if params[:data]
    unless id_list.kind_of?(Array)
      raise ArgumentError, "account_rows_grid.prepare_summary_page(): invalid or missing data parameter!", caller
    end
    return if id_list.size < 1
                                                    # Retrieve the rows from the ID list:
    records = nil
    begin
      records = AccountRow.where( :id => id_list )
    rescue
      raise ArgumentError, "account_rows_grid.prepare_summary_page(): no valid ID(s) found inside data parameter!", caller
    end
# DEBUG
#    logger.debug "accounts_controller.report_detail(): id list: #{id_list.inspect}"
    return if records.nil?

    date_from_lookup = params[:date_from_lookup]
    date_to_lookup = params[:date_to_lookup]
    record = records[0]

    if record.kind_of?( ActiveRecord::Base )        # == Init LABELS ==
      label_hash = {}                               # Initialize hash and extract all details column labels:
      header_record = Account.find( record.account_id )
                                                    # == CURRENCY == Store currency name for later usage:
      currency_name  = header_record.get_currency_name
      currency_short = header_record.get_currency_symbol
                                                    # == DATA COLLECTION == Detail data table + summary:
      # Compute summary sum via SQL mainly to get just the grand total, using the main
      # list of records:
      computed_sums = AccountRow.prepare_summary_hash(
          :records => records,
          :date_from_lookup => date_from_lookup,
          :date_to_lookup => date_to_lookup,
          :do_float_formatting => 1
      )
                                                    # Add the computed sums keys to the label hash:
      computed_sums.keys.each { |key|
        label_hash[ key ] = I18n.t( key, {:scope=>[:account_row]} )
      }

      { :after_prepare_summary_page => {:computed_sums => computed_sums, :label_hash => label_hash} }
    else
      { :after_prepare_summary_page => false }
    end
  end
  # ---------------------------------------------------------------------------


  # Displays the summary page pop-up with a bar chart (done in almost-pure ExtJS)
  #
  js_method :after_prepare_summary_page, <<-JS
    function( result ) {
      if ( result ) {                               // Retrieve parameters from result hash:
        var computedSums    = result['computedSums'];
        var labelHash       = result['labelHash'];
        var subtotalNames   = computedSums['subtotalNames'];
        var subtotalValues  = computedSums['subtotalValues'];
        var sortedIDs       = computedSums['subtotalOrder'];
                                                    // Build-up the verbose summary HTML list:
        var itemsHTMLList = "<h4>" + labelHash['subtotalNames'] + " / " + labelHash['subtotalValues'] + " (" + computedSums['currencyName'] +
                            ")</h4><table align='center' width='80%'>";
        var resultDataArray = new Array();          // In the meantime, build also the dataset for the model (it needs an Array, NOT an Hash)
        itemsHTMLList = itemsHTMLList + "<tr><td>(" + labelHash['startingTotal'] + ")</td><td align='right'>" +
                        computedSums['startingTotal'] + "</td></tr>";
        resultDataArray[ 0 ] = [
          -1, labelHash['startingTotal'], computedSums['startingTotal'], computedSums['currencyName']
        ];
        Ext.Array.each( sortedIDs, function( value, index, arrItself ) {
          var textValue = ( subtotalValues[ value ] < 0 ? "<span class='negativeValue'>" + subtotalValues[ value ] + '</span>' : subtotalValues[ value ] );
          itemsHTMLList = itemsHTMLList + "<tr><td><i>" + subtotalNames[ value ] + "</i></td><td align='right'>" +
                          textValue + "</td></tr>";
          resultDataArray[ index + 1 ] = [
            value, subtotalNames[ value ], subtotalValues[ value ], computedSums['currencyName']
          ];
        });
        itemsHTMLList = itemsHTMLList + "<tr><td><hr/></td><td><hr/></td></tr><tr><td><b>" + labelHash['grandTotal'] + "</b></td><td align='right'><b>" +
                        computedSums['grandTotal'] + "</b></td></tr></table>";

        Ext.require([
            'Ext.data.*',
            'Ext.data.reader.*',
            'Ext.chart.*',
            'Ext.fx.target.Sprite', 'Ext.layout.container.Fit',
            'Ext.Window'
        ]);

        Ext.define('SummaryChartDataModel', { extend: 'Ext.data.Model',
          fields: [
              {name: 'id', type: 'int'},
              {name: 'desc', type: 'string'},
              {name: 'subtot',  type: 'float'},
              {name: 'currency', type: 'string'}
          ]
        });

        var summaryChartStore = Ext.create('Ext.data.ArrayStore', {
          storeId: 'summaryChartStore',
          model: 'SummaryChartDataModel',
          data: resultDataArray,
          autoLoad: true,
          autoSynch: true
        });

        var win = Ext.create('Ext.window.Window', {
          title: "#{I18n.t(:summary_stats, :scope=>[:account_row])}",
          width: 750,
          height: 600,
          layout: 'fit',
          items: {
            xtype: 'container',
            layout: { type: 'hbox', align: 'stretch', pack: 'start' },
            items:
            [
              {
                html: itemsHTMLList,
                flex: 1
              },
              {
                xtype: 'chart',
                id: 'chartSummaryBar',
                animate: false,
                flex: 2,
                style: 'background:#fff',
                store: summaryChartStore,
                axes: [
                  {
                    type: 'Numeric',
                    position: 'bottom',
                    title: labelHash['subtotalValues'],
                    fields: ['subtot'],
                    grid: true,
                    label: {
                      renderer: Ext.util.Format.numberRenderer('0,0'),
                      font: '10px Arial'
                    }
                  },
                  {
                    type: 'Category',
                    position: 'left',
                    title: labelHash['subtotalNames'],
                    fields: ['desc'],
                  }
                ],
                series: [{
                    type: 'bar',
                    axis: 'bottom',
                    xField: 'desc',
                    yField: ['subtot'],
                    tips: {
                        trackMouse: true,
                        minWidth: 100,
                        maxWidth: 150,
                        minHeight: 40,
                        maxHeight: 60,
                        renderer: function( storeItem, item ) {
                          var v = storeItem.get('subtot');
                            this.setTitle( storeItem.get('desc') + ':<br/><p>' + v + ' ' + storeItem.get('currency') + '</p>' );
                        }
                    }
                }]
              }
            ]
          }
        }).show();
      }
      else {
        this.netzkeFeedback( "#{I18n.t(:warning_no_data_to_send)}" );
      }
    }  
  JS
  # ---------------------------------------------------------------------------
  # ---------------------------------------------------------------------------
end
