#
# == Invoices Analysis Filtering Panel component implementation
#
# - author: Steve A.
# - vers. : 0.25.20120927
#
# Similarly to FilteringDateRangePanel, this component that allows to set a date range
# with two date pickers.
# The date pickers will take their initial values from the configuration of component.
#
# The filtering range will be applied to extract the dataset used for the invoicing
# analysis and the rendering of the charts.
#
# The filtering fields (as well as their component IDs) that define the filtering range
# parameters are named: (self-explanatory, with unique ID and symbol equal to their name)
#
# - <tt>filtering_date_start</tt>, a.k.a. <tt>InvoicesAnalysisFilteringPanel::FILTERING_DATE_START_CMP_ID</tt>
# - <tt>filtering_date_end</tt>, a.k.a. <tt>InvoicesAnalysisFilteringPanel::FILTERING_DATE_END_CMP_ID</tt>
#
# By setting explicitly <tt>config[:show_current_user_firm] = true</tt> it is possible to show the
# current user's firm on the side of the date range selector. (Default: +nil+)
#
class InvoicesAnalysisFilteringPanel < Netzke::Basepack::Panel

  # Component Symbol used to uniquely address the date-start field of the range
  FILTERING_DATE_START_CMP_SYM  = :filtering_date_start

  # Component ID used to uniquely address the date-start field of the range
  FILTERING_DATE_START_CMP_ID   = FILTERING_DATE_START_CMP_SYM.to_s

  # Component Symbol used to uniquely address the date-end field of the range
  FILTERING_DATE_END_CMP_SYM    = :filtering_date_end

  # Component ID used to uniquely address the date-end field of the range
  FILTERING_DATE_END_CMP_ID     = FILTERING_DATE_END_CMP_SYM.to_s


  js_properties(
    :prevent_header => true,
    :header => false
  )

  # Internal data stores:
  js_property :analysis_data_store_by_year
  js_property :analysis_data_store_by_date
  # ---------------------------------------------------------------------------


  def configuration
    super.merge(
      :persistence => true,                         # This allows to have a stored component session
      :frame => true,
      :width => "98%",
      :min_width => 500,
      :min_height => 35,
      :height => 35,
      :margin => '1 1 1 1',
      :fieldDefaults => {
        :msgTarget => 'side',
        :autoFitErrors => false
      },
      :layout => 'hbox',
      :items => [
        {
          :fieldLabel => I18n.t(:data_filtered_from, :scope => [:agex_action]),
          :labelWidth => 130,
          :margin => '1 6 0 0',
          :id   => FILTERING_DATE_START_CMP_ID,
          :name => FILTERING_DATE_START_CMP_ID,
          :xtype => 'datefield',
          :vtype => 'daterange',
          :endDateField => FILTERING_DATE_END_CMP_ID,
          :width => 230,
          :enable_key_events => true,
          :format => AGEX_FILTER_DATE_FORMAT_EXTJS,
          :value => component_session[FILTERING_DATE_START_CMP_SYM] ||= super[FILTERING_DATE_START_CMP_SYM]
        },
        {
          :fieldLabel => I18n.t(:data_filtered_to, :scope => [:agex_action]),
          :labelWidth => 20,
          :margin => '1 2 0 6',
          :id   => FILTERING_DATE_END_CMP_ID,
          :name => FILTERING_DATE_END_CMP_ID,
          :xtype => 'datefield',
          :vtype => 'daterange',
          :startDateField => FILTERING_DATE_START_CMP_ID,
          :width => 120,
          :enable_key_events => true,
          :format => AGEX_FILTER_DATE_FORMAT_EXTJS,
          :value => component_session[FILTERING_DATE_END_CMP_SYM] ||= super[FILTERING_DATE_END_CMP_SYM]
        },
        {
          :xtype => :displayfield,
          :value => ( super[:show_current_user_firm] == true ? "(#{I18n.t(:firm__get_full_name)}: #{Netzke::Core.current_user.firm.get_full_name})" : '' ),
          :min_width => 150,
          :width => 350,
          :margin => '1 2 0 6'
        }
      ]
    )
  end
  # ---------------------------------------------------------------------------


  js_method :init_component, <<-JS
    function() {
      #{js_full_class_name}.superclass.initComponent.call(this);
                                                    // Add the additional 'advanced' VTypes used for validation:
      Ext.apply( Ext.form.field.VTypes, {
          daterange: function( val, field ) {
              var date = field.parseDate( val );
              if ( !date ) {
                  return false;
              }
                                  // 'startDateField' property will be defined only on END date
              if ( field.startDateField && (!this.dateRangeMax || (date.getTime() != this.dateRangeMax.getTime())) ) {
                  var startDt = Ext.ComponentManager.get( field.startDateField );
                  this.dateRangeMax = date;
                  startDt.setMaxValue( date );
                  startDt.validate();
              }
                                  // 'endDateField' property will be defined only on START date
              else if ( field.endDateField && (!this.dateRangeMin || (date.getTime() != this.dateRangeMin.getTime())) ) {
                  var endDt = Ext.ComponentManager.get( field.endDateField );
                  this.dateRangeMin = date;
                  endDt.setMinValue( date );
                  endDt.validate();
              }
              // Always return true since we are only using this vtype to set the
              // min/max allowed values (these are tested for after the vtype test)
              return true;
          }
      });

      this.addEventListenersFor( "#{FILTERING_DATE_START_CMP_ID}" );
      this.addEventListenersFor( "#{FILTERING_DATE_END_CMP_ID}" );
                                                    // Define the Models:
      Ext.define('InvoiceTotDataModel', {
          extend: 'Ext.data.Model',
          fields: [
            { name: 'date',         type: 'string' },
            { name: 'amount',       type: 'float' },
            { name: 'description',  type: 'string' }
          ]
      });
                                                    // Create the Data Stores:
      analysisDataStoreByYear = Ext.create( 'Ext.data.Store', {
              storeId: 'storeAnalysisDataByYear',
              model: 'InvoiceTotDataModel'
          }
      );
      analysisDataStoreByDate = Ext.create( 'Ext.data.Store', {
              storeId: 'storeAnalysisDataByDate',
              model: 'InvoiceTotDataModel'
          }
      );
      var currencyName = "#{Netzke::Core.current_user.get_default_currency_name_from_firm()}";
      this.createYearlyInvoicingChart( currencyName );
      this.createDailyInvoicingChart( currencyName );
                                                    // Retrieve values from both date controls:
      var sDateStart = this.getDateFor( "#{FILTERING_DATE_START_CMP_ID}" );
      var sDateEnd   = this.getDateFor( "#{FILTERING_DATE_END_CMP_ID}" );
      var opt = new Object;
      if ( sDateStart )
        opt[ "#{FILTERING_DATE_START_CMP_ID}" ] = sDateStart;
      if ( sDateEnd )
        opt[ "#{FILTERING_DATE_END_CMP_ID}" ] = sDateEnd;
                                                    // Call the endpoint to refresh (re-extract) data:
      if ( sDateStart && sDateEnd )
        this.refreshAnalysisData( opt ); 
    }  
  JS
  # ---------------------------------------------------------------------------


  # Adds the required event listeners for the specified dateField widget
  #
  js_method :add_event_listeners_for, <<-JS
    function( dateCtlName ) {                       // Retrieve the filtering date field sub-Component:
      var fltrDate = this.getComponent( dateCtlName );
  
      fltrDate.on(                                  // Add listener on value select:
        'select',
        function( field, value, eOpts ) {           // Retrieve values from both date controls:
          var sDateStart = this.getDateFor( "#{FILTERING_DATE_START_CMP_ID}" );
          var sDateEnd   = this.getDateFor( "#{FILTERING_DATE_END_CMP_ID}" );
          var opt = new Object;
          if ( sDateStart )
            opt[ "#{FILTERING_DATE_START_CMP_ID}" ] = sDateStart;
          if ( sDateEnd )
            opt[ "#{FILTERING_DATE_END_CMP_ID}" ] = sDateEnd;
                                                    // Call the endpoint to refresh (re-extract) data:
          if ( sDateStart && sDateEnd )
            this.refreshAnalysisData( opt );
        },
        this
      );

      fltrDate.on(                                  // Add listener on ENTER keypress:
        'keypress',
        function( field, eventObj, eOpts ) {
          if ( eventObj.getKey() == Ext.EventObject.ENTER ) {
            var sDateStart = this.getDateFor( "#{FILTERING_DATE_START_CMP_ID}" );
            var sDateEnd   = this.getDateFor( "#{FILTERING_DATE_END_CMP_ID}" );
            var opt = new Object;
            if ( sDateStart )
              opt[ "#{FILTERING_DATE_START_CMP_ID}" ] = sDateStart;
            if ( sDateEnd )
              opt[ "#{FILTERING_DATE_END_CMP_ID}" ] = sDateEnd;
                                                    // Call the endpoint to refresh (re-extract) data:
            if ( sDateStart && sDateEnd )
              this.refreshAnalysisData( opt );
          }
        },
        this
      );
    }
  JS
  # ---------------------------------------------------------------------------


  # Retrieves the current value of a filtering element.
  #
  js_method :get_date_for, <<-JS
    function( dateCtlName ) {                       // Retrieve the filtering date field sub-Component:
      var fltrDate = this.getComponent( dateCtlName );
      var sDate = false;
      try {
        sDate = Ext.Date.format( fltrDate.getValue(), "#{AGEX_FILTER_DATE_FORMAT_EXTJS}" );
      }
      catch(e) {
      }
      return sDate;
    }
  JS
  # ---------------------------------------------------------------------------


  # Creates and renders the 'yearly invoicing' chart panel.
  #
  js_method :create_yearly_invoicing_chart, <<-JS
    function( currencyName ) {                      // Render Yearly-invoicing chart:
      Ext.create( 'widget.panel', {
          width: "98%",
          height: 250,
          renderTo: 'div_invocing_by_year_chart',
          layout: 'fit',
          items: {
            id: 'chartYearlyInvoicing',
            xtype: 'chart',
            animate: true,
            shadow: true,
            store: analysisDataStoreByYear,
            axes: [
              {
                type: 'Numeric',
                position: 'left',
                fields: [ 'amount' ],
                title: currencyName,
                grid: {
                    odd: {
                        opacity: 1,
                        fill: '#ddd',
                        stroke: '#bbb',
                        'stroke-width': 1
                    }
                },
                minimum: 0,
                adjustMinimumByMajorUnit: 0,
                label: {
                    renderer: Ext.util.Format.numberRenderer('0,0'),
                    font: '10px Arial'
                }
              },
              {
                type: 'Category',
                position: 'bottom',
                fields: 'date',
                label: {
                    font: '10px Arial',
                    rotate: { degrees: 315 }
                }
              }
            ],
            series: [
                {
                  type: 'column',
                  axis: 'left',
                  highlight: true,
                  xField: 'date',
                  yField: [ 'amount' ],
                  tips: {
                      trackMouse: true,
                      minWidth: 210,
                      minHeight: 40,
                      renderer: function( storeItem, item ) {
                        this.setTitle( storeItem.get('date') );
                        this.update( storeItem.get('description') );
                      }
                  }
               },
                {
                  type: 'line',
                  axis: 'left',
                  xField: 'date',
                  yField: [ 'amount' ],
                  style: { opacity: 0.93 }
                }
            ]
          }
      });
      // ---------------------------------------------------------------- END of Yearly-invoicing Chart
    }
  JS
  # ---------------------------------------------------------------------------


  # Creates and renders the 'daily invoicing' chart panel.
  #
  js_method :create_daily_invoicing_chart, <<-JS
    function( currencyName ) {                      // Render Daily-invoicing chart:
      Ext.create( 'widget.panel', {
          width: "98%",
          height: 250,
          renderTo: 'div_invocing_by_date_chart',
          layout: 'fit',
          items: {
            id: 'chartDailyInvoicing',
            xtype: 'chart',
            animate: true,
            shadow: true,
            store: analysisDataStoreByDate,
            axes: [
              {
                type: 'Numeric',
                position: 'left',
                fields: [ 'amount' ],
                title: currencyName,
                grid: {
                    odd: {
                        opacity: 1,
                        fill: '#ddd',
                        stroke: '#bbb',
                        'stroke-width': 1
                    }
                },
                minimum: 0,
                adjustMinimumByMajorUnit: 0,
                label: {
                    renderer: Ext.util.Format.numberRenderer('0,0'),
                    font: '10px Arial'
                }
              },
              {
                type: 'Category',
                position: 'bottom',
                fields: 'date',
                label: {
                    font: '10px Arial',
                    rotate: { degrees: 315 }
                }
              }
            ],
            series: [
                {
                  type: 'column',
                  axis: 'left',
                  highlight: true,
                  xField: 'date',
                  yField: [ 'amount' ],
                  tips: {
                      trackMouse: true,
                      minWidth: 210,
                      minHeight: 40,
                      renderer: function( storeItem, item ) {
                        this.setTitle( storeItem.get('date') );
                        this.update( storeItem.get('description') );
                      }
                  },
                  renderer: function( sprite, record, attr, index, store ) {
                      var colorIdx = ( record.get('date').substr(0,4) % 5 );
                      var color = ['rgb(213, 70, 121)', 
                                   'rgb(44, 153, 201)', 
                                   'rgb(146, 6, 157)', 
                                   'rgb(49, 149, 0)', 
                                   'rgb(249, 153, 0)'][ colorIdx ];
                      return Ext.apply( attr, { fill: color } );
                  }                      
               },
                {
                  type: 'line',
                  axis: 'left',
                  xField: 'date',
                  yField: [ 'amount' ],
                  style: { opacity: 0.93 }
                }
            ]
          }
      });
      // ---------------------------------------------------------------- END of Daily-invoicing Chart
    }
  JS
  # ---------------------------------------------------------------------------


  # Endpoint for refreshing the "invoice analysis" data store.
  # Prepares the result hash of data that will be sent back to the internal Store
  # for the analysis charts and graphs.
  #
  # == Params (both are facultative)
  # - filtering_date_start : an ISO-formatted (Y-m-d) date with which the grid scope can be updated
  # - filtering_date_end : as above, but for the ending-date of the range
  #
  endpoint :refresh_analysis_data do |params|
#    logger.debug( "--- refresh_analysis_data: #{params.inspect}" )
                                                    # Validate params (preparing defaults)
    if params[FILTERING_DATE_START_CMP_SYM]
      date_from_lookup = params[FILTERING_DATE_START_CMP_SYM]
    else
      curr_year  = DateTime.now.strftime( '%Y' ).to_i
      date_from_lookup = Date.parse( "#{curr_year-10}-01-01" ).strftime( AGEX_FILTER_DATE_FORMAT_SQL )
    end

    if params[FILTERING_DATE_END_CMP_SYM]
      date_to_lookup = params[FILTERING_DATE_END_CMP_SYM]
    else
      curr_year  = DateTime.now.strftime( '%Y' ).to_i
      date_to_lookup = Date.parse( "#{curr_year+1}-01-01" ).strftime( AGEX_FILTER_DATE_FORMAT_SQL )
    end
                                                    # Update the component session:
    component_session[FILTERING_DATE_START_CMP_SYM] = date_from_lookup
    component_session[FILTERING_DATE_END_CMP_SYM]   = date_to_lookup
    firm_id = Netzke::Core.current_user.firm_id
# DEBUG
#    logger.debug( "After validate:\r\n- date_from_lookup => #{date_from_lookup}" )
#    logger.debug( "- date_to_lookup => #{date_to_lookup}" )
#    logger.debug( "- firm_id => #{firm_id}" )

    records = Invoice.where( ["(firm_id = ?) AND (date_invoice >= ?) AND (date_invoice <= ?)", firm_id, date_from_lookup, date_to_lookup] )
    summary_array = []
                                                    # Compute the summary for each invoice in filtering range:
    records.each { |row|
      summary_array << {
        :id => row.id, :name => row.name, :date => row.date_invoice.strftime( '%Y-%m-%d' ), :year => row.date_invoice.strftime( '%Y' ).to_i,
        :summary_hash => InvoiceRow.prepare_summary_hash( :parent_id => row.id )
      }
    }
    summary_by_year = compute_grouped_list( summary_array, :year )
    summary_by_date = compute_grouped_list( summary_array, :date )

    { :after_refresh_analysis_data => {
        :summary_by_year => summary_by_year,
        :summary_by_date => summary_by_date,
        :currency => summary_array.first[:summary_hash][:currency_name]
      } 
    }
  end


  # Computes the total amounts for a specific <tt>group_key_sym</tt> for the rows
  # of <tt>summary_array</tt> (which should hold all the summary rows computed with
  # the above method).
  #
  def compute_grouped_list( summary_array, group_key_sym )
    key_values_list = summary_array.collect{ |element| element[ group_key_sym ] }.uniq.sort
                                                    # For :year only, we use a fixed step of 1 "category" each:
    if ( group_key_sym == :year )
      key_values_list = (key_values_list.first .. key_values_list.last).collect{ |year| year }
    end

    result_list = key_values_list.collect{ |group_key_value|
      invoice_group = summary_array.find_all{ |el| el[ group_key_sym ] == group_key_value }
      total = 0
      invoice_group.each{ |el| total = total + el[:summary_hash][:grand_total] }
      currency_name = nil

      description = invoice_group.collect{ |el|
        currency_name = el[:summary_hash][:currency_name] unless currency_name 
        "<tr><td><i>#{el[:name]}:</i></td><td align='right'>#{sprintf('%.2f', el[:summary_hash][:grand_total].to_f)} #{currency_name}</td></tr>"
      }.join('')

      {
        group_key_sym => group_key_value,
        :amount => total,
        :description => "<table align='center' width='95%'>#{description}<tr><td><hr/></td><td><hr/></td></tr><tr><td></td><td align='right'><b>#{sprintf('%.2f', total)}</b> #{currency_name}</td></tr></table>"
      }
    }
  end
  # ---------------------------------------------------------------------------


  # Handles the update of the refreshed data, passed as JSON result
  #
  js_method :after_refresh_analysis_data, <<-JS
    function( result ) {
      if ( result ) {                               // Retrieve parameters from result hash:
        var currencyName  = result['currency'];
        var summaryByYear = result['summaryByYear'];
        var summaryByDate = result['summaryByDate'];

        analysisDataStoreByYear.removeAll();        // Clear the stores
        analysisDataStoreByDate.removeAll();

        var rowDataList = new Array();              // Store each row in a single array (thus adding data to the store triggers just 1 event)
        Ext.Array.each( summaryByYear, function( item, index, arrItself ) {
          rowDataList[ index ] = {
              date:         item.year,
              amount:       item.amount,
              description:  item.description
          };
        });
                                                    // Loading the data will automatically update the chart:
        analysisDataStoreByYear.loadData( rowDataList );

        var rowDataList = new Array();
        Ext.Array.each( summaryByDate, function( item, index, arrItself ) {
          rowDataList[ index ] = {
              date:         item.date,
              amount:       item.amount,
              description:  item.description
          };
        });
                                                    // Loading the data will automatically update the chart:
        analysisDataStoreByDate.loadData( rowDataList );
      }
      else {
        this.netzkeFeedback( "#{I18n.t(:warning_no_data_to_send)}" );
      }
    }
  JS
  # ---------------------------------------------------------------------------
  # ---------------------------------------------------------------------------
end
