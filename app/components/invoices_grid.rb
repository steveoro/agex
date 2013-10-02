#
# Specialized Invoices rows list/grid component implementation
#
# - author: Steve A.
# - vers. : 3.05.05.20131002
#
class InvoicesGrid < MacroEntityGrid

  action :add_new_invoice,:text => I18n.t(:new_invoice),
                          :tooltip => I18n.t(:new_invoice_tooltip),
                          :icon =>"/images/icons/email_add.png",
                          :disabled => ! ( Netzke::Core.current_user && Netzke::Core.current_user.can_do(:invoices, :add) )

  action :report_pdf,     :text => I18n.t(:report_pdf, :scope =>[:invoice_row]),
                          :tooltip => I18n.t(:report_pdf_tooltip, :scope =>[:invoice_row]),
                          :icon =>"/images/icons/page_white_acrobat.png",
                          :disabled => true

  action :report_pdf_copy,:text => I18n.t(:report_pdf_copy, :scope =>[:invoice_row]),
                          :tooltip => I18n.t(:report_pdf_copy_tooltip, :scope =>[:invoice_row]),
                          :icon =>"/images/icons/page_white_acrobat.png",
                          :disabled => true
  # ---------------------------------------------------------------------------

  js_property :target_for_ctrl_manage, Netzke::Core.controller.manage_invoice_path( :locale => I18n.locale, :id => -1 )
  # ---------------------------------------------------------------------------


  model 'Invoice'


  js_properties(
    :prevent_header => true,
    :border => false
  )

  edit_form_config        :class_name => "InvoiceDetails"
  edit_form_window_config :width => 810, :title => "#{I18n.t(:edit_invoice)}"


  # Override for default bottom bar:
  #
  def default_bbar
    start_items = [
      :report_pdf.action,
      :report_pdf_copy.action,
      "-",                                          # Adds a separator
      :show_details.action,
      :search.action,
      "-",                                          # Adds a separator
      :add_new_invoice.action,
      :edit.action
    ]
    possible_items = []                             # (Appointment "raw" delete must have same permission as Receipt delete)
    if ( Netzke::Core.current_user && Netzke::Core.current_user.can_do(:invoices, :del) )
      possible_items << :del.action
    end
    end_items = [
      :apply.action,
      "-",
      :edit_in_form.action,
      "-",
      :row_counter.action
    ]
    start_items + possible_items + end_items
  end


  # Override for default context menu
  #
  def default_context_menu
    start_items = [
      :row_counter.action,
      "-",                                          # Adds a separator
      :report_pdf.action,
      :report_pdf_copy.action,
      "-",                                          # Adds a separator
      :show_details.action,
      "-",                                          # Adds a separator
      :add_new_invoice.action,
      :edit.action
    ]
    possible_items = []
    if ( Netzke::Core.current_user && Netzke::Core.current_user.can_do(:invoices, :del) )
      possible_items << :del.action
    end
    end_items = [
      :apply.action,
      "-",
      :edit_in_form.action,
    ]
    start_items + possible_items + end_items
  end
  # ---------------------------------------------------------------------------


  def configuration
    # ASSERT: assuming current_user is always set for this grid component:
    super.merge(
      :persistence => true,
      # FIXME The Netzke endpoint, once configured, ignores any subsequent request to turn off or resize the pagination
      # TODO Either wait for a new Netzke release that changes this behaviour, or rewrite from scratch the endpoint implementation for the service of grid data retrieval
      :enable_pagination => ( toggle_pagination = AppParameter.get_default_pagination_enable_for( :invoices ) ),
      # [Steve, 20120914] It seems that the LIMIT parameter used during column sort can't be toggled off even when pagination is false, so we put an arbitrary 10Tera row count limit per page to get all the rows: 
      :rows_per_page => ( toggle_pagination ? AppParameter.get_default_pagination_rows_for( :invoices ) : 1000000000000 ),

      :min_width => 750,

      # [20120221] This field is required by model, but we are silently filtering by the firm, so we use
      # a strong default to enforce its value:
      :strong_default_attrs => {
          :firm_id => Netzke::Core.current_user.firm_id
      }.merge( super[:strong_default_attrs] || {} ),

      :columns => [
          { :name => :created_on, :label => I18n.t(:created_on), :width => 80,  :read_only => true,
            :format => 'Y-m-d', :summary_type => :count },
          { :name => :updated_on, :label => I18n.t(:updated_on), :width => 120, :read_only => true,
            :format => 'Y-m-d' },
          { :name => :name,               :label => I18n.t(:name) },
          { :name => :description,        :label => I18n.t(:description), :width => 200 },
          # [Steve, 20120221] See note above. Column filtered but kept here as reference:
#          { :name => :firm__get_full_name, :label => I18n.t(:firm__get_full_name), :width => 100,
#            :scope => lambda {|rel| rel.house_firms.still_available},
#            :default_value => Netzke::Core.current_user.firm_id },

          { :name => :recipient_firm__get_full_name, :label => I18n.t(:recipient_firm__get_full_name),
            :width => 100,
            # [20121121] For the combo-boxes to have a working query after the 4th char is entered in the edit widget,
            # a lambda statement must be used. Using a pre-computed scope from the Model class prevents Netzke
            # (as of this version) to append the correct WHERE clause to the scope itself (with an inline lambda, instead, it works).
            :scope => lambda {|rel| rel.committers.still_available.order("name ASC")},
            :sorting_scope => :sort_invoice_by_firm
          },
          { :name => :invoice_number, :label => I18n.t(:invoice_number), :width => 50,
            :xtype => 'numbercolumn', :align => 'right', :format => '0' },
          { :name => :date_invoice, :label => I18n.t(:date_invoice), :width => 80,
            :format => 'Y-m-d', :default_value => DateTime.now },
          { :name => :header_object, :label => I18n.t(:header_object), :width => 200 },
          { :name => :is_fully_payed, :label => I18n.t(:is_fully_payed),
            :default_value => false, :unchecked_value => 'false'
          },

          { :name => :social_security_cost, :label => I18n.t(:social_security_cost), :width => 80,
            :xtype => 'numbercolumn', :align => 'right', :format => '0.00' },
          { :name => :vat_tax, :label => I18n.t(:vat_tax), :width => 50,
            :xtype => 'numbercolumn', :align => 'right', :format => '0.00' },
          { :name => :account_wage, :label => I18n.t(:account_wage), :width => 80,
            :xtype => 'numbercolumn', :align => 'right', :format => '0.00' },
          { :name => :total_expenses, :label => I18n.t(:total_expenses), :width => 80,
            :xtype => 'numbercolumn', :align => 'right', :format => '0.00', :summary_type => :sum },
          { :name => :le_currency__display_symbol, :label => I18n.t(:le_currency, {:scope=>[:activerecord, :models]}),
            :width => 40,
            # [20121121] See note above for the sorted combo boxes.
            :scope => lambda { |rel| rel.order("display_symbol ASC") },
            :sorting_scope => :sort_invoice_by_currency,
            :default_value => Netzke::Core.current_user.get_default_currency_id_from_firm()
          },
          { :name => :le_invoice_payment_type__get_full_name, :label => I18n.t(:le_invoice_payment_type__get_full_name),
            # [20121121] See note above for the sorted combo boxes.
            :scope => lambda { |rel| rel.order("name ASC") },
            :sorting_scope => :sort_invoice_by_payment_type, :width => 150
          },
          { :name => :notes, :label => I18n.t(:notes), :width => 200 }
      ]
    )
  end
  # ---------------------------------------------------------------------------


  js_method :init_component, <<-JS
    function() {
      #{js_full_class_name}.superclass.initComponent.call(this);
                                                    // Stack another listener on top over the one defined in EntityGrid:
      this.getSelectionModel().on('selectionchange',
        function(selModel) {
          var canFreeEdit = ( "#{ Netzke::Core.current_user && Netzke::Core.current_user.can_do(:invoices, :free_edit) }" != 'false' );
          var selItems = selModel.selected.items;
                                                    // Disable PDF creation when there is nothing selected to print:
          this.actions.reportPdf.setDisabled( selModel.getCount() < 1 );
          this.actions.reportPdfCopy.setDisabled( selModel.getCount() < 1 );
                                                    // Toggle on-off actions according to selected context:
          this.actions.edit.setDisabled( !canFreeEdit );
          this.actions.editInForm.setDisabled( !canFreeEdit );
        },
        this
      );
                                                    // Skip edit events in some cases:
      this.getPlugin('celleditor').on( 'beforeedit',
        function( editEvent, eOpts ) {
          var canFreeEdit = ( "#{ Netzke::Core.current_user && Netzke::Core.current_user.can_do(:invoices, :free_edit) }" != 'false' );
          // [20130211] Note that "!= 'true'" takes into account both undefined and false values for getter fields returning string booleans
// DEBUG
//          console.log( "canFreeEdit=" + canFreeEdit );
          editEvent.cancel = ( ! canFreeEdit );
        },
        this
      );
                                                    // As soon as the grid is ready, sort it by default:
      this.on( 'viewready',
        function( gridPanel, eOpts ) {
          gridPanel.store.sort([ { property: 'date_invoice', direction: 'DESC' } ]);
        },
        this
      );
    }
  JS
  # ---------------------------------------------------------------------------
  # ---------------------------------------------------------------------------


  # Front-end JS event handler for the action <tt>add_new_invoice</tt>
  #
  js_method :on_add_new_invoice, <<-JS
    function() {
      Ext.MessageBox.confirm( "#{I18n.t(:confirmation, {:scope=>[:netzke,:basepack,:grid_panel]})}", "#{I18n.t(:are_you_sure, {:scope=>[:netzke,:basepack,:grid_panel]})}",
        function( responseText ) {
          if ( responseText == 'yes' ) {        // -- Add NEW INVOICE on confirm:
            this.doAddNewInvoice({ firm_id: this.initialConfig.strongDefaultAttrs['firmId'] });
          }
        },
        this
      );
    }
  JS
  # ---------------------------------------------------------------------------


  # Back-end method for new row creation, with preset default values.
  #
  # == Params:
  # - firm_id => current firm ID
  #
  endpoint :do_add_new_invoice do |params|
    logger.debug "\r\n!! ------ in :do_add_new_invoice( firm_id: #{params[:firm_id]} ) -----"
    firm_id = params[:firm_id]
    is_ok = false

    if ( firm_id.to_i > 0 )                         # Create a new Invoice:
      logger.debug "Adding new empty Invoice record for firm_id #{firm_id}..."
      begin
        invoice = Invoice.new(
          :firm_id => firm_id,
          :recipient_firm_id => firm_id,
          :header_object => '---'
        )
        invoice.preset_default_values()
        invoice.save!                               # raise automatically an exception if save is not successful
      rescue
        logger.error( "\r\n*** InvoicesGrid::do_add_new_invoice(): exception caught during save!" )
        logger.error( "*** #{ $!.to_s }\r\n" ) if $!
      else
        is_ok = true
      end
    else
      logger.warn('InvoicesGrid::do_add_new_invoice(): nothing to do, wrong parameters.')
    end
    { :after_do_add_new_invoice => is_ok }
  end
  # ---------------------------------------------------------------------------


  # Refreshes the data set.
  #
  js_method :after_do_add_new_invoice, <<-JS
    function( result ) {
      if ( result ) {
        this.netzkeFeedback( "#{I18n.t(:row_added)}" );
        this.getStore().load();
      }
      else {
        this.netzkeFeedback( "#{I18n.t(:something_went_wrong)}" );
      }
    }  
  JS
  # ---------------------------------------------------------------------------
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
  # ---------------------------------------------------------------------------


  # Invokes a controller path sending in all the (encoded) IDs currently available on
  # the data store.
  # Does not add any other filters added through the search dialog.
  #
  js_method :invoke_filtered_ctrl_method, <<-JS
    function( controllerPath ) {                    // Compose the data array with just the IDs:
      var selModel = this.getSelectionModel();

      if ( selModel.hasSelection() ) {
        var selItems = selModel.selected.items;
        if ( selItems.length > 0 ) {                // If there is a valid selection, send a request:
          var id = selItems[0].data.id;
          if ( id > 0 ) {                           // Redirect to this URL: (which performs a send_data rails command)
            location.href = controllerPath + "&invoice_id=" + id;
          }
          else {
            this.netzkeFeedback( "#{I18n.t(:warning_no_data_to_send)}" );
          }
        }
      }
    }
  JS
  # ---------------------------------------------------------------------------
  # ---------------------------------------------------------------------------
end
