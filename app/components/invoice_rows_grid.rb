#
# Specialized Invoice rows list/grid component implementation
#
# - author: Steve A.
# - vers. : 3.03.14.20130419
#
# == Params
#
# :+invoice_id+ must be set during component configuration and must point to the current header's Account.id
# :+default_currency_id+ must point to the default currency id that has to be used
#
class InvoiceRowsGrid < Netzke::Basepack::GridPanel

  action :row_counter,  :text => I18n.t(:click_on_the_grid), :disabled => true
  # ---------------------------------------------------------------------------

  action :report_pdf,   :text => I18n.t(:report_pdf, :scope =>[:invoice_row]),
                        :tooltip => I18n.t(:report_pdf_tooltip, :scope =>[:invoice_row]),
                        :icon =>"/images/icons/page_white_acrobat.png"
  action :report_pdf_copy,
                        :text => I18n.t(:report_pdf_copy, :scope =>[:invoice_row]),
                        :tooltip => I18n.t(:report_pdf_copy_tooltip, :scope =>[:invoice_row]),
                        :icon =>"/images/icons/page_white_acrobat.png"

  action :report_odt,   :text => I18n.t(:report_odt, :scope =>[:invoice_row]),
                        :tooltip => I18n.t(:report_odt_tooltip, :scope =>[:invoice_row]),
                        :icon =>"/images/icons/page_white_word.png"
  action :report_odt_copy,
                        :text => I18n.t(:report_odt_copy, :scope =>[:invoice_row]),
                        :tooltip => I18n.t(:report_odt_copy_tooltip, :scope =>[:invoice_row]),
                        :icon =>"/images/icons/page_white_word.png"

  action :report_txt,   :text => I18n.t(:report_txt, :scope =>[:invoice_row]),
                        :tooltip => I18n.t(:report_txt_tooltip, :scope =>[:invoice_row]),
                        :icon =>"/images/icons/page_white_text.png"
  # ---------------------------------------------------------------------------

  action :export_csv_full,
                        :text => I18n.t(:export_csv_full, :scope =>[:invoice_row]),
                        :tooltip => I18n.t(:export_csv_full_tooltip, :scope =>[:invoice_row]),
                        :icon =>"/images/icons/page_white_excel.png"

  action :export_csv_no_header,
                        :text => I18n.t(:export_csv_no_header, :scope =>[:invoice_row]),
                        :tooltip => I18n.t(:export_csv_no_header_tooltip, :scope =>[:invoice_row]),
                        :icon =>"/images/icons/page_white_excel.png"
  # ---------------------------------------------------------------------------

  model 'InvoiceRow'

  js_properties(
    :prevent_header => true,
    :features => [{ :ftype => 'summary' }],
    :border => false
  )


  add_form_window_config  :width => 500, :title => "#{I18n.t(:add_invoice_row)}"
  edit_form_window_config :width => 500, :title => "#{I18n.t(:edit_invoice_row)}"


  js_property :tbar, [
    # XXX (Custom actions not needed for now:)
    # {
      # :menu => [
        # "W.I.P. - Custom actions",
      # ],
      # :text => I18n.t(:add_default_row),
      # :icon => "/images/icons/database_add.png"
    # },
    {
      :menu => [:report_pdf.action, :report_pdf_copy.action, :report_odt.action, :report_odt_copy.action, :report_txt.action],
      :text => I18n.t(:reporting),
      :icon => "/images/icons/report.png"
    },
    {
      :menu => [:export_csv_full.action],
      :text => I18n.t(:data_export),
      :icon => "/images/icons/folder_table.png"
    }
  ]


  # Override for default bottom bar:
  #
  def default_bbar
    [
      :add.action, :edit.action, :apply.action, :del.action,
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
#          { :name => :created_on,         :label => I18n.t(:created_on), :width => 80,   :read_only => true,
#            :format => 'Y-m-d' },
#          { :name => :updated_on,         :label => I18n.t(:updated_on), :width => 120,  :read_only => true,
#            :format => 'Y-m-d' },

          { :name => :project__get_full_name, :label => I18n.t(:project__get_full_name),
            :sorting_scope => :sort_invoice_row_by_project
          },
          { :name => :description,        :label => I18n.t(:description), :min_width => 200,
            :flex => 1, :summary_type => :count },

          { :name => :quantity,           :label => I18n.t(:quantity), :width => 60,
            :xtype => 'numbercolumn', :align => 'right', :format => '0.00', :summary_type => :sum },
          { :name => :le_invoice_row_unit__get_full_name, :label => I18n.t(:le_invoice_row_unit__get_full_name),
            :sorting_scope => :sort_invoice_row_by_unit
          },
          { :name => :unit_cost,          :label => I18n.t(:unit_cost), :width => 60,
            :xtype => 'numbercolumn', :align => 'right', :format => '0.00', :summary_type => :sum },
          { :name => :le_currency__display_symbol, :label => I18n.t(:le_currency, {:scope=>[:activerecord, :models]}), :width => 40,
            :default_value => super[:default_currency_id], :sorting_scope => :sort_invoice_row_by_currency
          },
          { :name => :vat_tax,            :label => I18n.t(:vat_tax), :width => 50,
            :xtype => 'numbercolumn', :align => 'right', :format => '0.00',
            :default_value => (i = Invoice.find_by_id(super[:invoice_id])) ? i.vat_tax.to_f : 0.0
          },
          { :name => :discount,           :label => I18n.t(:discount), :width => 50,
            :xtype => 'numbercolumn', :align => 'right', :format => '0.00'
          }
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
    }  
  JS

  # ---------------------------------------------------------------------------


  # Front-end JS event handler for the action 'report_pdf'
  #
  js_method :on_report_pdf, <<-JS
    function(){
      this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.report_detail_invoices_path(:type=>'pdf')}" );
    }
  JS

  # Front-end JS event handler for the action 'report_pdf_copy'
  #
  js_method :on_report_pdf_copy, <<-JS
    function(){
      this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.report_detail_invoices_path(:type=>'pdf',:is_internal_copy=>1)}" );
    }
  JS

  # Front-end JS event handler for the action 'report_odt'
  #
  js_method :on_report_odt, <<-JS
    function(){
      this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.report_detail_invoices_path(:type=>'odt')}" );
    }
  JS

  # Front-end JS event handler for the action 'report_odt_copy'
  #
  js_method :on_report_odt_copy, <<-JS
    function(){
      this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.report_detail_invoices_path(:type=>'odt',:is_internal_copy=>1)}" );
    }
  JS

  # Front-end JS event handler for the action 'report_txt'
  #
  js_method :on_report_txt, <<-JS
    function(){
      this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.report_detail_invoices_path(:type=>'txt')}" );
    }
  JS

  # Front-end JS event handler for the action 'export_csv_full'
  #
  js_method :on_export_csv_full, <<-JS
    function(){
      this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.report_detail_invoices_path(:type=>'full.csv')}" );
    }
  JS

  # FIXME NOT USED / NOT NEEDED YET:

  # Front-end JS event handler for the action 'export_csv_no_header'
  # [Steve, 20120306] Using 'no header' as a synonym of a single-table layout or 'flat'
  #                   (since multi-table with no-headers doesn't make much sense)
  #
  js_method :on_export_csv_no_header, <<-JS
    function(){
      this.invokeFilteredCtrlMethod( "#{Netzke::Core.controller.report_detail_invoices_path(:type=>'simple.csv',:layout=>'flat')}" );
    }
  JS
  # ---------------------------------------------------------------------------


  # Invokes a controller path sending in all the (encoded) IDs currently available on
  # the data store.
  # Does not add any other filters added through the search dialog.
  #
  js_method :invoke_filtered_ctrl_method, <<-JS
    function( controllerPath ) {                    // Compose the data array with just the IDs:
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
        location.href = controllerPath + "&data=" + encodedData;
      }
      else {
        this.netzkeFeedback( "#{I18n.t(:warning_no_data_to_send)}" );
      }
    }
  JS
  # ---------------------------------------------------------------------------
  # ---------------------------------------------------------------------------
end
