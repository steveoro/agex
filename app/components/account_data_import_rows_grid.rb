#
# Specialized AccountDataImportRows grid component implementation
#
# - author: Steve A.
# - vers. : 3.03.15.20130422
#
# == Params
#
# :+invoice_id+ must be set during component configuration and must point to the current header's Invoice.id
# :+default_currency_id+ must point to the default currency id that has to be used
#
class AccountDataImportRowsGrid < Netzke::Basepack::GridPanel

  action :row_counter,  :text => I18n.t(:click_on_the_grid), :disabled => true
  # ---------------------------------------------------------------------------

  action :commit_rows,  :text => I18n.t(:commit_rows),
                        :tooltip => I18n.t(:commit_rows_tooltip),
                        :icon =>"/images/icons/database_save.png"
  # ---------------------------------------------------------------------------

  model 'AccountDataImportRow'

  js_properties(
    :prevent_header => true
  )


  add_form_window_config  :width => 500, :title => "#{I18n.t(:add_account_row)}"
  edit_form_window_config :width => 500, :title => "#{I18n.t(:edit_account_row)}"


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
     :commit_rows.action,
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
      # [Steve, 20120131]
      # FIXME The Netzke endpoint, once configured, ignores any subsequent request to turn off or resize the pagination
      # TODO Either wait for a new Netzke release that changes this behaviour, or rewrite from scratch the endpoint implementation for the service of grid data retrieval
      :enable_pagination => false,
      # [Steve, 20120914] It seems that the LIMIT parameter used during column sort can't be toggled off, so we put an arbitrary 10Tera row count limit per page to get all the rows: 
      :rows_per_page => 1000000000000,
      :min_width => 750,

      :columns => [
          { :name => :num, :label => '#', :xtype => 'rownumberer', :read_only => true },
          { :name => :user__name, :label => I18n.t(:user), :width => 70, :default_value => Netzke::Core.current_user.id,
            :sorting_scope => :netzke_sort_data_import_users_row_by_name
          },
          { :name => :account__name, :label => I18n.t(:account, {:scope=>[:activerecord,:models]}) },
          { :name => :date_entry, :label => I18n.t(:date_entry, {:scope=>[:account_row]}), :width => 80,
            :format => 'Y-m-d', :default_value => DateTime.now },

          { :name => :entry_value,     :label => I18n.t(:entry_value, {:scope=>[:account_row]}), :width => 60,
            :xtype => 'numbercolumn', :align => 'right', :format => '0.00'},
          { :name => :le_currency__display_symbol,    :label => I18n.t(:le_currency, {:scope=>[:activerecord, :models]}), :width => 40,
            :default_value => super[:default_currency_id],
            :sorting_scope => :netzke_sort_data_import_currencies_by_display_symbol
          },

          { :name => :parent_le_account_row_type__get_full_name, :label => I18n.t(:parent_le_account_row_type__get_full_name, {:scope=>[:account_row]}),
            :sorting_scope => :netzke_sort_data_import_parent_row_types_by_name
          },
          { :name => :le_account_row_type__get_full_name, :label => I18n.t(:le_account_row_type__get_full_name, {:scope=>[:account_row]}),
            :sorting_scope => :netzke_sort_data_import_row_types_by_name
          },
          { :name => :le_account_payment_type__get_full_name, :label => I18n.t(:le_account_payment_type__get_full_name, {:scope=>[:account_row]}),
            :sorting_scope => :netzke_sort_data_import_payment_types_by_name
          },
          { :name => :recipient_firm__get_full_name, :label => I18n.t(:recipient_firm__get_full_name, {:scope=>[:account_row]}),
            :sorting_scope => :netzke_sort_data_import_recipient_firm_by_name
          },

          { :name => :description, :label => I18n.t(:description), :width => 280 },

          { :name => :get_verbose_conflicting_account_row, :label => I18n.t(:data_import_conflicting_account_row, {:scope=>[:account_row]}),
            :width => 280,
            :sorting_scope => :netzke_sort_data_import_conflicting_rows_id
          },
          { :name => :text_1, :label => I18n.t(:data_import_source_text_1, {:scope=>[:account_row]}),
            :width => 450
          },

          { :name => :check_number, :label => I18n.t(:check_number, {:scope=>[:account_row]}) },
          { :name => :notes, :label => I18n.t(:notes), :flex => 1 }
      ]
    )
  end

  # ---------------------------------------------------------------------------


  js_method :init_component, <<-JS
    function() {
      #{js_full_class_name}.superclass.initComponent.call(this);

      // Update in real time the enabled state of the available actions:
      this.getSelectionModel().on(
        'selectionchange',
        function(selModel) {
          var gridStore = this.getStore();
          var iConflictIDFound = 0;
          gridStore.each (
            function( record ) {
              if ( record.data.get_verbose_conflicting_account_row.length > 0  ) {
                iConflictIDFound += 1;
              }
            },
            this
          );
          this.actions.rowCounter.setText( '#{I18n.t(:tot_rows)}: ' + gridStore.getCount() + ' / #{I18n.t(:selected)}: ' + selModel.getCount() + ' / #{I18n.t(:in_conflict)}: ' + iConflictIDFound );
        },
        this
      );
                                                    // As soon as the grid is ready, sort it by default:
      this.on( 'viewready',
        function( gridPanel, eOpts ) {
          gridPanel.store.sort([ { property: 'date_entry', direction: 'ASC' } ]);
        },
        this
      );
    }  
  JS

  # ---------------------------------------------------------------------------
  # ---------------------------------------------------------------------------

  # Front-end JS event handler for the action 'commit_rows'
  #
  js_method :on_commit_rows, <<-JS
    function() {
      Ext.MessageBox.confirm( this.i18n.confirmation, this.i18n.areYouSure,
        function(btn) {
          if (btn == 'yes') {
            this.invokePostOnHiddenForm( 'frmPostImportData', 'data' );
          }
        },
        this
      );
    }
  JS
  # ---------------------------------------------------------------------------


  # Invokes a controller path sending in all the (encoded) IDs currently available on
  # the data store.
  #
  js_method :invoke_post_on_hidden_form, <<-JS
    function( formId, dataFieldId ) {
      var gridStore = this.getStore();
      var rowArray = new Array();
      gridStore.each(
        function( record ) {
          rowArray.push( record.data.id );
        },
        this
      );
                                                    // If there is data, process it:
      if ( rowArray.length > 0 ) {
        var encodedData = Ext.JSON.encode( rowArray );
        var form = Ext.get( formId );
        var hiddenField = Ext.get( dataFieldId );
        hiddenField.dom.value = encodedData;
        form.dom.submit();
      }
      else {
        this.netzkeFeedback( "#{I18n.t(:warning_no_data_to_send)}" );
      }
    }
  JS
  # ---------------------------------------------------------------------------
  # ---------------------------------------------------------------------------
end
