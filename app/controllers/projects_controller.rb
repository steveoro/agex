# encoding: utf-8

class ProjectsController < ApplicationController
  require 'common/format'
  require 'ruport'
  require 'fileutils'                               # Used to process filenames
  require 'project_row_layout'
  require 'documatic'

  # Require authorization before invoking any of this controller's actions:
  before_filter :authorize


  # Default action ("/projects")
  def index
# DEBUG
#    logger.debug( "\r\n\r\n---[ #{controller_name()}.index ] ---" )
#    logger.debug( "Params: #{params.inspect()}" )
    ap = AppParameter.get_parameter_row_for( :projects )
    @max_view_height = ap.get_view_height()
                                                    # Having the parameters, apply the resolution and the radius backwards:
    start_date = DateTime.now.strftime( ap.get_filtering_resolution )
                                                    # Set the (default) parameters for the scope configuration: (actual used value will be stored inside component_session[])
    @filtering_date_start  = ( Date.parse( start_date ) - ap.get_filtering_radius ).strftime( AGEX_FILTER_DATE_FORMAT_SQL )
    @filtering_date_end    = ( Date.parse( start_date ) + ap.get_filtering_radius ).strftime( AGEX_FILTER_DATE_FORMAT_SQL )
# DEBUG
#    logger.debug( "start_date: #{start_date.inspect()}" )
#    logger.debug( "@filtering_date_start: #{@filtering_date_start.inspect()}" )
#    logger.debug( "@filtering_date_end:   #{@filtering_date_end.inspect()}" )
    @context_title = I18n.t(:projects_list)
  end


  # Manage a single project using +id+ as parameter
  #
  def manage
#    logger.debug( "* Manage Project ID: #{params[:id]}" )
    @project_id = params[:id]
    project = Project.find_by_id( @project_id )
    redirect_to( projects_path() ) and return unless project

    @project_name = project.name
    @default_currency_id = ( project.le_currency_id ? project.le_currency_id : project.get_default_currency_id() )
    @current_team_id = ( project.team_id ? project.team_id : nil )
    @default_human_resource_id = ( project.team ? project.team.get_first_human_resource_id() : nil )
                                                    # Compute the filtering parameters:
    ap = AppParameter.get_parameter_row_for( :projects )
    @max_view_height = ap.get_view_height()
                                                    # Having the parameters, apply the resolution and the radius backwards:
    start_date = DateTime.now.strftime( ap.get_filtering_resolution )
                                                    # Set the (default) parameters for the scope configuration: (actual used value will be stored inside component_session[])
    @filtering_date_start  = ( Date.parse( start_date ) - ap.get_filtering_radius ).strftime( AGEX_FILTER_DATE_FORMAT_SQL )
    @filtering_date_end    = ( Date.parse( start_date ) + ap.get_filtering_radius ).strftime( AGEX_FILTER_DATE_FORMAT_SQL )
    @context_title = "#{I18n.t(:manage_project)} '#{@project_name}'"
  end


  # Sub-page for Milestones management for a single project, using +id+ as parameter
  #
  def milestones
#    logger.debug( "* Milestones for Project ID: #{params[:id]}" )
    @project_id = params[:id]
    project = Project.find_by_id( @project_id )
    redirect_to( projects_path() ) and return unless project

    @project_name = project.name
    @default_currency_id = ( project.le_currency_id ? project.le_currency_id : project.get_default_currency_id() )
    @current_team_id = ( project.team_id ? project.team_id : nil )
    @default_human_resource_id = ( project.team ? project.team.get_first_human_resource_id() : nil )
                                                    # Compute the filtering parameters:
    ap = AppParameter.get_parameter_row_for( :projects )
    @max_view_height = ap.get_view_height()
    @context_title = "#{I18n.t(:project_milestones_for)} \'#{@project_name}\'"
  end


  # Sub-page for Activity graph rendering for a single project, using +id+ as parameter
  #
  def activity
#    logger.debug( "* Activity graph for Project ID: #{params[:id]}" )
    @project_id = params[:id]
    project = Project.find_by_id( @project_id )
    redirect_to( projects_path() ) and return unless project

    @project_name = project.name
                                                    # Retrieve all the data rows for the chart graph, assuring that each date entry is unique (and cumulative)
    grouped_by_date_rows = ProjectRow.where( :project_id => @project_id ).select( "date_format(date_entry, '%Y-%m-%d') as single_date_entry, sum(std_hours) as std_hours_tot, sum(ext_hours) as ext_hours_tot" ).group( :single_date_entry )
                                                    # Retrieve also the data rows for the pie graph, grouping by each human resource:
    grouped_by_resource_rows = ProjectRow.where( :project_id => @project_id ).select( "human_resources.name as resource, sum(std_hours) as std_hours_tot, sum(ext_hours) as ext_hours_tot" ).joins( :human_resource ).group( :human_resource_id )

    array_of_date_rows     = grouped_by_date_rows.collect {|row| row.serializable_hash }
    array_of_resource_rows = grouped_by_resource_rows.collect {|row| row.serializable_hash }

    # [Steve, 20120215] The localized name for the field, to be displayable inside the chart legend must
    # be a single word with no special chars in it (no dots, comma, parenthesis, ...)
    @resource_name   = I18n.t(:resource_displayable_name, {:scope => [:project_row]})
    @date_entry_name = I18n.t(:date_entry_displayable_name, {:scope => [:project_row]})
    @std_hours_name  = I18n.t(:std_hours_displayable_name, {:scope => [:project_row]})
    @ext_hours_name  = I18n.t(:ext_hours_displayable_name, {:scope => [:project_row]})
                                                    # Format each row and assign each attributes to a new hash with displayable keys:
    verbose_array = array_of_date_rows.inject([]) { |arr, e|
      arr << {
        @date_entry_name => e['single_date_entry'],
        @std_hours_name  => e['std_hours_tot'].to_i,
        @ext_hours_name  => e['ext_hours_tot'].to_i
      }
    }
    @project_date_rows = verbose_array.to_json.gsub(/\"/,"'")

    verbose_array = array_of_resource_rows.inject([]) { |arr, e|
      arr << {
        @resource_name  => e['resource'],
        @std_hours_name => e['std_hours_tot'].to_i,
        @ext_hours_name => e['ext_hours_tot'].to_i
      }
    }
    @project_resource_rows = verbose_array.to_json.gsub(/\"/,"'")
# DEBUG
#    logger.debug("\r\n\r\n!! ----- report_detail -----")
#    logger.debug("activity params #{params.inspect}")
#    logger.debug("----------------------------------------------------------")
#    logger.debug("@project_date_rows: #{@project_date_rows.inspect}")
#    logger.debug("----------------------------------------------------------")
#    logger.debug("@project_resource_rows: #{@project_resource_rows.inspect}")
#    logger.debug("----------------------------------------------------------\r\n")
    @context_title = "#{I18n.t(:project_activity_for)} \'#{@project_name}\'"
  end
  # ---------------------------------------------------------------------------
  # ---------------------------------------------------------------------------


  # Outputs a detailed report containing both the Project header and the selected rows,
  # specified with an array of ProjectRow IDs.
  #
  # == Params:
  #
  # - <tt>:type</tt> => the extension of the file to be created; one among: 'pdf', 'odt', 'txt', 'full.csv', 'simple.csv'
  #   (default: 'pdf')
  #
  # - <tt>:data</tt> (*required*) => a JSON-encoded array of ProjectRow IDs to be retrieved and processed
  #
  # - <tt>:date_from_lookup</tt> / <tt>:date_to_lookup</tt> => 
  #   String dates representing the starting and ending filter range for this collection of rows.
  #   Both are not required (none, one or both can be supplied as options).
  #
  # - <tt>:separator</tt> => text separator used only for data export; default: ';'
  #
  # - <tt>:layout</tt> => either 'flat' or 'tab' [default], to specify the export data layout used
  #   (both usable for CSV and TXT output files)
  #
  # - <tt>:no_header</tt> => when +true+, the header of the output will be skipped.
  #
  def report_detail
#    logger.debug "\r\n!! ----- report_detail -----"
#    logger.debug "report_detail: params #{params.inspect}"
                                                    # Parse params:
    id_list = ActiveSupport::JSON.decode( params[:data] ) if params[:data]
    unless id_list.kind_of?(Array)
      raise ArgumentError, "projects_controller.report_detail(): invalid or missing data parameter!", caller
    end
    return if id_list.size < 1
                                                    # Retrieve the project rows from the ID list:
    records = nil
    begin
      records = ProjectRow.where( :id => id_list )
    rescue
      raise ArgumentError, "projects_controller.report_detail(): no valid ID(s) found inside data parameter!", caller
    end
# DEBUG
#    logger.debug "projects_controller.report_detail(): id list: #{id_list.inspect}"
    return if records.nil?
#    logger.debug "projects_controller.report_detail(): records class: #{records.class}"
#    logger.debug "projects_controller.report_detail(): records found: #{records.size}"

    filetype    = params[:type] || 'pdf'
    separator   = params[:separator] || ';'         # (This plus the following params are used only during data exports)
    use_layout  = (params[:layout].nil? || params[:layout].empty?) ? :tab : params[:layout].to_sym
    skip_header = (params[:no_header] == 'true' || params[:no_header] == '1')
                                                    # Obtain header row:
    record = records[0]
    if record.kind_of?( ActiveRecord::Base )        # == Init LABELS ==
      label_hash = {                                # Initialize hash and extract all details column labels:
        :project => I18n.t( :project, {:scope=>[:activerecord, :models]} )
      }
      header_record = Project.find( record.project_id )
      (                                             # Extract all possible report labels: (only if not already present)
        header_record.serializable_hash.keys +
        record.serializable_hash.keys +
        Project.report_label_symbols() +
        Project.report_header_symbols() +
        ProjectRow.report_detail_symbols() +
        ProjectRow::BOOL_FIELDS_SYMS
      ).each { |e|
        label_hash[e.to_sym] = I18n.t( e.to_sym, {:scope=>[:project_row]} ) unless label_hash[e.to_sym]
      }
# FIXME [Steve, 20120224] Previous versions to speed up preparation, used:
#    label_hash = get_cached_label_hash( record )

                                                    # == DATA Collection == (Data must be converted under a common currency)
      report_data_hash = prepare_report_data_hash(
          header_record,
          records,
          label_hash,
          {
            :rjustification => (filetype == 'txt' ? 15 : 0),
            :do_float_formatting => (filetype =~ /txt|pdf|odt/) != nil ? 1 : nil,
            :add_separator_row_for_subtables => (filetype =~ /pdf|odt|csv/) != nil ? false : true
          }
      )

      label_hash = report_data_hash[:label_hash]    # Retrieve the updated label_hash
      currency = report_data_hash[:currency_short]  # (Use report_data_hash[:currency_name].titleize if the PDF default font does not support the special currency symbols)
      ProjectRow::CURRENCY_SYMS.each { |e|          # Add verbose currency display to column title:
        label_hash[e.to_sym] = "#{label_hash[e.to_sym]} (#{currency})"
      }

                                                    # == OPTIONS setup + RENDERING phase ==
      filename = create_unique_filename( report_data_hash[:report_base_name] ) + ".#{filetype}"


      if ( filetype == 'pdf' )                      # --- PDF ---
        options = {
          :date_from           => params[:date_from_lookup].to_s.gsub(/\'/,''),
          :date_to             => params[:date_to_lookup].to_s.gsub(/\'/,'')
        }.merge!( report_data_hash )
                                                    # == Render layout & send data:
        send_data(
            ProjectRowLayout.render( options ),
            :type => 'application/pdf',
            :filename => filename
        )
        # -------------------------------------------


      elsif ( filetype == 'odt' )                   # --- ODT ---
        filename = "public/output/#{filename}"
        options = {
          # For documatic report output the following terms are the only ones that count, the others
          # could either be stored in :options or in :data for the process template:
          # (Note how the template file depends upon the currently set locale)
          :date_from        => params[:date_from_lookup].to_s.gsub(/\'/,''),
          :date_to          => params[:date_to_lookup].to_s.gsub(/\'/,''),
          :template_file    => "lib/odt_layouts/project_status_#{I18n.locale}.odt",
          :output_file      => filename,
          :current_datetime => DateTime.now.strftime("[%Y-%m-%d, %H:%M:%S]")
        }.merge!( header_record.prepare_report_header_hash() )
                                                    # == Render layout & send data:
        Documatic::OpenDocumentText::Template.process_template(
            :options => Ruport::Controller::Options.new( options ),
            :data => report_data_hash
        )
        logger.info( "[I!]-- Created documatic Project report '#{filename}'." )
        FileUtils.chmod( 0644, filename )
        send_file( filename )                       # send the generated file to the outside world
        # -------------------------------------------

                                                    # --- TXT & DATA EXPORT formats ---
      else
        data = prepare_custom_export_data( report_data_hash, filetype, separator, use_layout, skip_header )
# DEBUG
#        puts data
        send_data( data, :type => "text/#{filetype}", :filename => filename )
        # -------------------------------------------
      end
    end
  end
  # ---------------------------------------------------------------------------


  # Builds a new Invoice using the specified project row IDs.
  #
  # == Params:
  #
  # - <tt>:type</tt> => the type of Invoice that has to be created;
  #   currently supported/implemented:
  #     => 'grouped'  = 1 invoice row for each cost type among all the specified rows (uses project summary)
  #     => 'all'      = 1 single invoice row containing the whole cost of the project
  #     => 'esteem'   = 1 single invoice row containing just the esteemed cost of the project
  #
  # - <tt>:data</tt> => a JSON-encoded array of ProjectRow IDs to be retrieved and processed
  #
  # - <tt>:date_from_lookup</tt> / <tt>:date_to_lookup</tt> => 
  #   String dates representing the starting and ending filter range for this collection of rows.
  #   Both are not required (none, one or both can be supplied as options).
  #
  # - <tt>:recipient_is_partner</tt> => when true (default: nil), the invoice will use the Project.committer_firm_id as the recipient,
  #   instead of the Project.partner_firm_id.
  # - <tt>:create_detailed_voices</tt> => when true (default: nil) an InvoiceRow will be generated for each summary row of the project.
  #   (Standard hours total, extended hours total, extra expenses and tot. km)
  #
  def create_invoice_from_project
    logger.debug "\r\n!! ----- create_invoice_from_project -----"
    logger.debug "create_invoice_from_project: params #{params.inspect}"
                                                    # Parse params:
    id_list = ActiveSupport::JSON.decode( params[:data] ) if params[:data]
    unless id_list.kind_of?(Array)
      raise ArgumentError, "projects_controller.create_invoice_from_project(): invalid or missing data parameter!", caller
    end
    return if id_list.size < 1
                                                    # Retrieve the project rows from the ID list:
    records = nil
    begin
      records = ProjectRow.where( :id => id_list )
    rescue
      raise ArgumentError, "projects_controller.create_invoice_from_project(): no valid ID(s) found inside data parameter!", caller
    end
# DEBUG
#    logger.debug "projects_controller.create_invoice_from_project(): id list: #{id_list.inspect}"
    return if records.nil?
#    logger.debug "projects_controller.create_invoice_from_project(): records class: #{records.class}"
#    logger.debug "projects_controller.create_invoice_from_project(): records found: #{records.size}"

    record = records[0]
    if record.kind_of?( ActiveRecord::Base )
      recipient_is_partner   = (params[:type] =~ /partner/) != nil 
      create_detailed_voices = (params[:type] =~ /grouped/) != nil 
      use_forfait_esteem     = (params[:type] =~ /esteem/) != nil 
                                                    # Obtain header row:
      project = Project.find( record.project_id )
      invoice_id = -1

      begin                                         # --- BEGIN...rescue...else...end ---
        raise "unable to retrieve the specified project!" unless project
        raise "can't invoce this project since it has been already invoiced!" if project.has_been_invoiced?
        raise "recipient firm is invalid!" if recipient_is_partner && (project.partner_firm_id.nil? || (project.partner_firm_id < 1))
                                                    # Obtain the grouping for each item that has to be invoiced:

                                                    # Obtain the grouping for each item that has to be invoiced computing the summary for the project:
        project_summary = ProjectRow.prepare_summary_hash( :records => records )

        Invoice.transaction do                      # === BEGIN master transaction ===
          invoice = Invoice.new()                   # Create a new Invoice
          invoice.preset_default_values( :firm_id => project.firm_id )
          invoice.total_expenses = project_summary[:extra_expenses]
          invoice.le_currency_id = project_summary[:currency_id]
          invoice.recipient_firm_id = recipient_is_partner ? project.partner_firm_id : project.committer_firm_id

          invoice.header_object = project.description
          invoice.description = "#{I18n.t(:invoice_for, :scope =>[:invoice_row])} #{project.codename} (#{recipient_is_partner ? project.get_partner_name : project.get_committer_name})"
          invoice.notes = project.notes
          invoice.save!                             # raise automatically an exception if save is not successful
          invoice_id = invoice.id                   # Retrieve the ID of the newly created invoice: store & use it for each new InvoiceRow

          if create_detailed_voices
            add_invoice_row( invoice_id,            # Add 1 row for the standard working hours cost
                            project_summary[:std_hours],
                            (project_summary[:cost_std_hour].to_f + project_summary[:charge_std_hour].to_f) / project_summary[:std_hours].to_f,
                            project_summary[:currency_id],
                            record.project_id,
                            I18n.t(:analysis_dev_debug, :scope =>[:project_row]),
                            LeInvoiceRowUnit::HOUR_ID
            ) unless project_summary[:std_hours].to_i == 0

            add_invoice_row( invoice_id,            # Add 1 row for the "external" working hours cost
                            project_summary[:ext_hours],
                            (project_summary[:cost_ext_hour].to_f + project_summary[:charge_ext_hour].to_f) / project_summary[:ext_hours].to_f,
                            project_summary[:currency_id],
                            record.project_id,
                            I18n.t(:ext_analysis_dev_debug, :scope =>[:project_row]),
                            LeInvoiceRowUnit::HOUR_ID
            ) unless project_summary[:ext_hours].to_i == 0

            add_invoice_row( invoice_id,            # Add 1 row for the mileage cost
                            project_summary[:km_tot],
                            project_summary[:cost_km_tot].to_f / project_summary[:km_tot].to_f,
                            project_summary[:currency_id],
                            record.project_id,
                            I18n.t(:km_cost_for_trips, :scope =>[:project_row]),
                            LeInvoiceRowUnit::KM_ID
            ) unless project_summary[:km_tot].to_i == 0

          else
            add_invoice_row( invoice_id,            # Add 1 single row containing just the grand total
                            1,
                            use_forfait_esteem ? project.esteemed_price : project_summary[:grand_total],
                            project_summary[:currency_id],
                            record.project_id,
                            I18n.t(:forfait_amount_for_analysis_and_dev, :scope =>[:project_row]),
                            nil
            )
          end

# TODO / FUTURE_DEV If successful, toggle the invoiced flag on the project (but only if no more rows are available and the project is closed || toggle the flag if not yet toggled)
# FIXME The following update should be done only when no more project rows are left to be invoiced and the project has been flagged as "closed".
# TODO retrieve the above condition values (prj flags + total prj rows) 
                                                    # Finally, set project as "invoiced":
#          project.update_attribute( :has_been_invoiced, true )
        end                                         # === END master transaction ===

      rescue                                        # --- begin...RESCUE...else...end ---
        logger.error( "\r\n*** Invoice.create_from_project(): exception caught during save!" )
        logger.error( "*** #{ $!.to_s }\r\n" ) if $!
# FIXME Flash:
        flash[:error] = "#{I18n.t(:invoice_not_created, :scope =>[:invoice_row])}: #{$! ?  I18n.t( $!.to_s ) : I18n.t(:something_went_wrong)}"
        # TODO TEST this
        redirect_to( manage_project_path( :id => project.id ) )
#          redirect_to( :controller => 'projects', :action => 'manage', :id => params[:id] )
      else                                          # --- begin...rescue...ELSE...end ---
# FIXME Flash:
        flash[:info] = I18n.t(:project_invoiced_successfully, :scope =>[:project_row])
        # TODO TEST this
        redirect_to( manage_invoice_path( :id => invoice_id ) )
#        redirect_to( :controller => 'invoices', :action => 'manage', :id => invoice_id )
      end                                           # --- begin...rescue...else...END ---
    end
  end
  # ---------------------------------------------------------------------------


  private


  # Creates a new invoice row using the specified parameters.
  #
  def add_invoice_row( invoice_id, quantity, unit_cost, le_currency_id, project_id, description, le_invoice_row_unit_id )
    invoice_row = InvoiceRow.new
    invoice_row.invoice_id      = invoice_id
    invoice_row.quantity        = quantity
    invoice_row.unit_cost       = unit_cost
    invoice_row.le_currency_id  = le_currency_id
    invoice_row.project_id      = project_id
    invoice_row.description     = description
    invoice_row.le_invoice_row_unit_id = le_invoice_row_unit_id
    invoice_row.preset_default_values()             # this will not overwrite pre-set values
    invoice_row.save!                               # raise automatically an exception if save is not successful
  end
  # ---------------------------------------------------------------------------
  #++


  # Prepares the hash of data that will be used for report layout formatting.
  #
  # === Parameters:
  # - +header_record+ => Header (or parent entity) row associated with the current Model instance
  #
  # - +records+ => an ActiveRecord::Relation result to be processed as the main dataset
  #
  # - +label_hash+ => Hash container for all the text labels and strings that have been localized and are ready to be used
  #
  # === Additional options: (inside +options+ hash)
  # - <tt>:rjustification</tt> => numbers of blank fillers to be used for fixed-width floats;
  #   this is useful actually only for text file formatting, for PDF files ignore this option
  #   (justification is column based and layout-specific). Defaults to 0.
  #
  # - <tt>:do_float_formatting</tt> => set this != nil to convert to text and enforce a fixed text format for each float value
  #
  # - <tt>:add_separator_row_for_subtables</tt> =>
  #   when +true+ (default) adds a row for each partial sums subtable containing a series of
  #   dashes ("-------") to separate the subtable from the data, just for the sake of readability.
  #
  def prepare_report_data_hash( header_record, records, label_hash, options = {} )
    unless records.kind_of?( ActiveRecord::Relation )
      raise ArgumentError, "projects_controller.prepare_report_data_hash(): invalid records parameter!", caller
    end
    unless header_record.kind_of?( ActiveRecord::Base )
      raise ArgumentError, "projects_controller.prepare_report_data_hash(): invalid header_record parameter!", caller
    end
                                                    # == CURRENCY == Store currency name for later usage:
    currency_name  = header_record.get_currency_name
    currency_short = header_record.get_currency_symbol
                                                    # == DATA COLLECTION == Detail data table + summary:
    data_table = ProjectRow.prepare_report_detail(  # Build the data set into Ruport's Table class
        :records => records,
        :include_boolean_fields => false,
        :rjustification => options[:rjustification].to_i
    )
                                                    # Compute summary sum via SQL mainly to get just the grand total, using just the main constraint from the parent entity:
    computed_sums = ProjectRow.prepare_summary_hash(
      :records => records,
      :do_float_formatting => options[:do_float_formatting]
    )
    grouping_total = computed_sums[:grand_total].to_s
                                                    # == SUBTABLES PROCESSING ==
    report_data_hash = preprocess_report_data(
      :data_table => data_table,
      :add_separator_row_for_subtables => options[:add_separator_row_for_subtables]
    )

    result_hash = {                                 # Prepare result hash:
      :report_title     => header_record.get_title_names().join(" - "),
      :report_base_name => header_record.get_base_name(),
      :data_table       => data_table,
      :currency_name    => currency_name,
      :currency_short   => currency_short,             # (currency display symbol or short name)
      :label_hash       => label_hash,              # (This should be already translated and containing all the required label symbols)
      :parent_record    => header_record,
      :grouping_total   => grouping_total
    }.merge!( report_data_hash )

    result_hash
  end
  # ----------------------------------------------------------------------------



  # Prepares the output text for any custom data export format
  #
  # == Parameters:
  # - <tt>report_data_hash</tt> => the output hash returned by <tt>prepare_report_data_hash()</tt>
  # - +filetype+ => the format of the output text ('txt', 'simple.csv', ...)
  # - +separator+ 
  # - <tt>use_layout</tt> => the symbol of the data export layout to be used (either <tt>:flat</tt> or <tt>:tab</tt> [default])
  #   (both usable for CSV and TXT output files)
  # - <tt>skip_header</tt> => when +true+, the header of the output will be skipped.
  #
  # === Supported parameters for <tt>report_data_hash</tt>:
  # All options returned by <tt>prepare_report_data_hash()</tt>, plus:
  #
  # - <tt>:data_table</tt> => <tt>Ruport::Data::Table</tt> instance containing the data rows to be processed.
  # - <tt>:summary</tt> => hash of values as returned by <tt>prepare_summary_hash()</tt>.
  #
  def prepare_custom_export_data( report_data_hash, filetype = 'txt', separator = ';',
                                  use_layout = :tab, skip_header = false )
    data = ''

    unless skip_header                              # --- REPORT HEADER: ---
      header_record = report_data_hash[:parent_record]
      report_header_hash = header_record.prepare_report_header_hash()
      # Note: retrieving the report_header_hash here is necessary, since main prepare_report_data_hash()
      #       does not prepare it.
      Project.report_header_symbols().each { |key|
        data << I18n.t( key, {:scope=>[:project_row]} )
        data << "#{separator}#{report_header_hash[key]}\r\n"
      }
      data << "\r\n"
    end
                                                    # Check all supported layouts:
    if use_layout == :tab                           # == GROUPED LAYOUT (with sub-tables) ==
                                                    # Cost summary:
      data << I18n.t(:resource_summary_title, {:scope=>[:project_row]}) + ":"
      data << "\r\n"
      localize_ruport_table_column_names( report_data_hash[:cost_summary], :project_row, report_data_hash[:label_hash] )
      if ( filetype =~ /csv/ )
        data << report_data_hash[:cost_summary].as( :csv, :format_options => {:col_sep => separator}, :ignore_table_width => true )
      else
        data << report_data_hash[:cost_summary].as( :text, :ignore_table_width => true )
      end
      data << "\r\n\r\n"
                                                    # Entry types:
      data << I18n.t(:entry_type, {:scope=>[:project_row]}) + ":"
      data << "\r\n"
      localize_ruport_table_column_names( report_data_hash[:entry_types_table], :project_row, report_data_hash[:label_hash] )
      if ( filetype =~ /csv/ )
        data << report_data_hash[:entry_types_table].as( :csv, :format_options => {:col_sep => separator}, :ignore_table_width => true )
      else
        data << report_data_hash[:entry_types_table].as( :text, :ignore_table_width => true )
      end
      data << "\r\n\r\n"
                                                    # Data grouping:
      report_data_hash[:data_grouping].each { |name,grp|
        data << I18n.t(:resource, {:scope=>[:project_row]}) + ": " << name.to_s
        data << "\r\n"                              # merge the data with the subtotals before renaming the columns:
        grp += report_data_hash[:subtot_tables_hash][name]
        localize_ruport_table_column_names( grp, :project_row, report_data_hash[:label_hash] )        
        if ( filetype =~ /csv/ )
          data << grp.as( :csv, :format_options => {:col_sep => separator}, :ignore_table_width => true, :show_group_headers => false )
        else
          data << grp.as( :text, :ignore_table_width => true, :show_group_headers => false )
        end
        data << "\r\n\r\n"
      }
                                                    # Grandtotal table:
      data << I18n.t(:global_summary_title, {:scope=>[:project_row]}) + ":"
      data << "\r\n"                                # merge the data with the subtotals before renaming the columns:
      report_data_hash[:grandtot_table] += report_data_hash[:grandtot_sums]
      localize_ruport_table_column_names( report_data_hash[:grandtot_table], :project_row, report_data_hash[:label_hash] )
      if ( filetype =~ /csv/ )
        data << report_data_hash[:grandtot_table].as( :csv, :format_options => {:col_sep => separator}, :ignore_table_width => true )
      else
        data << report_data_hash[:grandtot_table].as( :text, :ignore_table_width => true )
      end
      data << "\r\n\r\n"

    elsif use_layout == :flat                       # == FLAT LAYOUT ==
                                                    # apply the localized names before outputting:
      localize_ruport_table_column_names( report_data_hash[:data_table], :project_row, report_data_hash[:label_hash] )        
      if ( filetype =~ /csv/ )
        data << report_data_hash[:data_table].as( :csv, :format_options => {:col_sep => separator}, :ignore_table_width => true, :show_group_headers => false )
      else
        data << report_data_hash[:data_table].as( :text, :ignore_table_width => true, :show_group_headers => false )
      end
      data << "\r\n"

    else                                            # == Any unsupported layout specified? ==
      data = "\r\n-- Unsupported layout format '#{use_layout}' specified! --\r\n\r\n"
    end
                                                    # Computed grandtotal:
    grouping_total = report_data_hash[:grouping_total].to_s + ' ' + report_data_hash[:currency_name].to_s
    data << I18n.t( :grouping_total_label, {:scope=>[:project_row]} ) + ": " << grouping_total << "\r\n"

    data
  end
  # ---------------------------------------------------------------------------



  # Converts the column name symbol of a specific amount to the corresponding
  # column name of its cost.
  #
  def get_cost_symbol_of( sym )
    sym == :km_tot ? :cost_km : "cost_#{sym}".sub(/hours/, "hour").to_sym 
  end

  # Converts the column name symbol of a specific amount to the corresponding
  # column name of its recharge price (or cost).
  #
  def get_charge_symbol_of( sym )
    "charge_#{sym}".sub(/hours/, "hour").to_sym 
  end


  # This method provides the core of the business logic behind the <tt>ProjectRows</tt> model printouts.
  #
  # === Parameters:
  #
  # - <tt>:data_table</tt> =>
  #   a <tt>Ruport::Data::Table</tt> containing all detail data to be (pre)processed to obtain various
  #   sub-tables, groupings and totals.
  #
  # - <tt>:add_separator_row_for_subtables</tt> =>
  #   when +true+ (default) adds a row for each partial sums subtable containing a series of
  #   dashes ("-------") to separate the subtable from the data, just for the sake of readability.
  #
  # === Returns:
  #
  # An Hash of already-computed & easily reportable data chunks, composed of the following keys:
  #
  # - <tt>:cost_summary</tt> =>
  #   a <tt>Ruport::Data::Table</tt> obtained from the cost summary among the data grouping
  #   selecting unique values of human_resource as main key.
  #   See <tt>Ruport::Data::Grouping.summary()</tt>.
  #
  # - <tt>:data_grouping</tt> =>
  #   a <tt>Ruport::Data::Grouping</tt> (which is an Hash of <tt>Ruport::Data::Group</tt>) containing a data group
  #   for each value of human_resource among each data row of this project_id.
  #
  # - <tt>:subtot_tables_hash</tt> =>
  #   an Hash composed of Group name with <tt>Ruport::Data::Table</tt> pairs, one for each 
  #   name of the data_grouping. Each table contains just the additional computation
  #   rows (5 in total) to be added to the data table before the rendering.
  #
  # - <tt>:grandtot_table</tt> =>
  #   a <tt>Ruport::Data::Table</tt> summarizing each subtotal for each data group.
  #
  # - <tt>:grandtot_sums</tt> =>
  #   the subtable portion of the table above, containing just the grandtotal computation.
  #   To be rendered together with grandtot_table.
  #
  # - <tt>:entry_types_table</tt> =>
  #   a <tt>Ruport::Data::Table</tt> summarizing each possible code value of the field entry_type.
  #
  def preprocess_report_data( options_hash = {} )
    data_table = options_hash[:data_table]
    unless data_table.kind_of?( Ruport::Data::Table )
      raise "projects_controller.preprocess_report_data(): the data_table option is required, specifying a Ruport::Data::Table containing all the detail data for the processing."
    end
    add_separator_row_for_subtables = options_hash[:add_separator_row_for_subtables].nil? ? true : options_hash[:add_separator_row_for_subtables]
                                                    # --- (SUB)TABLES PREPARATION ---
                                                    # Create a grouping from the complete data set
    data_grouping = Ruport::Data::Grouping.new( data_table, :by => :human_resource )
                                                    # Check for invalid group name(s) and re-sort the bunch:
    data_grouping.sort_grouping_by! { |g| g.name.nil? ? "" : g.name }
# DEBUG
#   puts "DATA GROUPING table..."
#   puts data_grouping.as( :text, :ignore_table_width => true )
                                                    # Prepare a cost summary from the grouping
    cost_summary = data_grouping.summary( :resource,
        :cost_std_hour         => lambda { |g| g.column(:cost_std_hour)[0].to_f + g.column(:charge_std_hour)[0].to_f },
        :cost_ext_hour         => lambda { |g| g.column(:cost_ext_hour)[0].to_f + g.column(:charge_ext_hour)[0].to_f },
        :cost_km               => lambda { |g| g.column(:cost_km)[0].to_f },
# TODO fixed weekly wage must become fixed *daily* wage in next version of AgeX!!! (As it is, it's not really useful)
#        :fixed_weekly_wage     => lambda { |g| g.column(:fixed_weekly_wage)[0].to_f + g.column(:charge_weekly_wage)[0].to_f },
#        :percentage_of_invoice => lambda { |g| g.column(:percentage_of_invoice)[0].to_f },

# FIXME [20100705, Steve] if all 6 columns are used, the auto-table formatting system will mess up column widths clearing
#       the resource column contents, but only if it's column #0, or if fixed order is removed (commenting out the following hash term)
        :order => [
            :resource, :cost_std_hour, :cost_ext_hour, :cost_km,
#            :fixed_weekly_wage,
#            :percentage_of_invoice
        ]
    )
# DEBUG
#    puts "COST SUMMARY table..."
#    puts cost_summary.as( :text, :ignore_table_width => true )

    subtot_tables_hash = {}                         # Create a hash for holding all the tables for each group subtotals
                                                    # Iterate on the grouping to compute a subtotal table for each group:
    # For each group inside the grouping, a subtotals "summary" subtable will be manually generated,
    # creating 4 specific rows:
    # 1) one containing sums for all the summable column values (using sigma),
    # 2) one for reporting the unitary costs for all the summable column values,
    # 3) one reporting a verbose display of the computation to be performed (a string display, e.g.: "15 x 10.0")
    # 4) one reporting the actual result of the computation (a float, e.g.: 150.0)
    data_grouping.each { |n,g|
      subtot_table = Ruport::Data::Table.new :data => [], :column_names => g.column_names
                                                    # add a separator row:
      subtot_table << g.column_names.collect do |sym|
        "--------"
      end if add_separator_row_for_subtables
                                                    # compute sums for each sigma column & add the row:
      subtot_table << g.column_names.collect do |sym|
        case sym.to_s
        when /date_entry/
          I18n.t( :sums )
        when /_hours|km_tot|extra_expenses/
          g.sigma(sym)
        else
          nil
        end
      end
# DEBUG
#      puts "SubTotal table... PHASE 1"
#      puts subtot_table.as( :text, :ignore_table_width => true )
                                                    # create a unitary cost row, displayable under the same table; each value must be <> nil to be summable:
      subtot_table << g.column_names.collect do |sym|
        case sym
        when :date_entry
          I18n.t( :costs )
        when :std_hours, :ext_hours
          idx1 = get_cost_symbol_of(sym)
          idx2 = get_charge_symbol_of(sym)          # (As per table definitions the single resource cost and its recharge price are at least 0.0 but never nil)
          g.column(idx1).nil? || g.column(idx2).nil? ? 0.0 : g.column(idx1)[0].to_f + g.column(idx2)[0].to_f
        when :km_tot
          idx = get_cost_symbol_of(sym)
          (g.column(idx).nil? || g.column(idx)[0].nil?) ? 0.0 : g.column(idx)[0].to_f
        else
          nil
        end
      end
# DEBUG
#      puts "SubTotal table... PHASE 2"
#      puts subtot_table.as( :text, :ignore_table_width => true )
                                                    # Create a "verbose" result row, displayable under the same table:
      subtot_table << g.column_names.collect do |sym|
        case sym
        when :std_hours, :ext_hours
          idx1 = get_cost_symbol_of(sym)
          idx2 = get_charge_symbol_of(sym)          # (As per table definitions the single resource cost and it recharge price are at least 0.0 but never nil)
          (g.column(idx1).nil? || g.column(idx2).nil?) ? "" : (g.column(idx1)[0].to_f + g.column(idx2)[0].to_f).to_s + " x " + g.sigma(sym).to_s
        when :km_tot
          idx = get_cost_symbol_of(sym)
          (g.column(idx).nil? || g.column(idx)[0].nil?) ? "" : (g.column(idx)[0]).to_s + " x " + g.sigma(sym).to_s
        else
          nil
        end
      end
# DEBUG
#      puts "SubTotal table... PHASE 3"
#      puts subtot_table.as( :text, :ignore_table_width => true )
                                                    # Create a subtable result row, displayable under the same table:
      subtot_table << g.column_names.collect do |sym|
        case sym
        when :date_entry
          I18n.t( :subtotals )
        when :std_hours, :ext_hours
          idx1 = get_cost_symbol_of(sym)
          idx2 = get_charge_symbol_of(sym)          # (As per table definitions the single resource cost and it recharge price are at least 0.0 but never nil)
          g.column(idx1).nil? || g.column(idx2).nil? ? 0.0 : (g.column(idx1)[0].to_f + g.column(idx2)[0].to_f) * g.sigma(sym)
        when :km_tot
          idx = get_cost_symbol_of(sym)
          g.column(idx).nil? ? 0.0 : g.column(idx)[0].to_f * g.sigma(sym)
        when :extra_expenses
          g.column(sym).nil? ? 0.0 : g.sigma(sym)
        else
          nil
        end
      end                                           # Remove unnecessary columns before storing the subtotals
# DEBUG
#      puts "SubTotal table... PHASE 4"
#      puts subtot_table.as( :text, :ignore_table_width => true )
                                                    # table into the holding hash and releasing the current group:
      subtot_table.remove_columns(ProjectRow::ROW_COST_SYMS + ProjectRow::BOOL_FIELDS_SYMS)
      subtot_tables_hash.merge!( n => subtot_table )
      g.remove_columns(ProjectRow::ROW_COST_SYMS + ProjectRow::BOOL_FIELDS_SYMS)
    } 
                                                    # Prepare a grandtotal "summary" table:
    grandtot_table = Ruport::Data::Table.new(
        :data => [],
        :column_names => [ :human_resource, :cost_std_hour, :cost_ext_hour, :cost_km, :extra_expenses, :totals ]
    )
                                                    # Iterate on each group name to get its summary (sub)table and extract its subtotal
    data_grouping.each { |name,grp|                 # record row  (the last one), renaming accordingly its columns:
      subtot_rec = subtot_tables_hash[name][ subtot_tables_hash[name].length-1 ].clone
      subtot_rec.rename_attribute(:date_entry, :human_resource)
      subtot_rec.rename_attribute(:std_hours, :cost_std_hour)
      subtot_rec.rename_attribute(:ext_hours, :cost_ext_hour)
      subtot_rec.rename_attribute(:km_tot, :cost_km)
      subtot_rec.rename_attribute(:entry_type, :totals)
      subtot_rec[:human_resource] = name
      subtot_rec[:totals] = subtot_rec[:cost_std_hour].to_f + subtot_rec[:cost_ext_hour].to_f +
                            subtot_rec[:cost_km].to_f + subtot_rec[:extra_expenses].to_f
      grandtot_table << subtot_rec                  # Add the subtotal record row to the summary of totals
    }                                               # (non-used attributes will be ignored)
                                                    # Prepare a final grandtotal (sub)table containing just a couple of rows:
    grandtot_sums = Ruport::Data::Table.new(
        :data => [],
        :column_names => grandtot_table.column_names
    )
                                                    # add a separator row:
    grandtot_sums << grandtot_table.column_names.collect do |sym|
      "--------"
    end if add_separator_row_for_subtables

    grandtot_sums << grandtot_table.column_names.collect do |sym|
      case sym.to_s                                 # compute the sums for all the columns
      when /date_entry/
        I18n.t( :grand_total )
      when /_hour|km|extra_expenses/
        grandtot_table.sigma(sym)
      else
        nil
      end
    end
                                                    # Finally update the grand total using the subtotal sums computed above:
    grandtot_sums[ grandtot_sums.length-1 ][:totals] = 0.0
    for i in [:cost_std_hour, :cost_ext_hour, :cost_km, :extra_expenses]
      grandtot_sums[ grandtot_sums.length-1 ][:totals] += grandtot_sums[ grandtot_sums.length-1 ][i].to_f unless grandtot_sums[ grandtot_sums.length-1 ][i].nil?
    end

    entry_types_table = Ruport::Data::Table.new(
      :data => ProjectRow.get_entry_type_description_array,
      :column_names => [:code, :description]
    )

    return {
      :cost_summary => cost_summary,
      :data_grouping => data_grouping, :subtot_tables_hash => subtot_tables_hash,
      :grandtot_table => grandtot_table, :grandtot_sums => grandtot_sums,
      :entry_types_table => entry_types_table
    }
  end
  # ----------------------------------------------------------------------------
  #++
end
