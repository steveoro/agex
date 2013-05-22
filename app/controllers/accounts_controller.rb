# encoding: utf-8

class AccountsController < ApplicationController
  require 'common/format'
  require 'ruport'
  require 'fileutils'                               # Used to process filenames
  require 'account_row_layout'
  require 'documatic'

  # Require authorization before invoking any of this controller's actions:
  before_filter :authorize


  # Default action ("/accounts")
  def index
    ap = AppParameter.get_parameter_row_for( :accounts )
    @max_view_height = ap.get_view_height()
  end


  # Manage a single account using +id+ as parameter
  #
  def manage
#    logger.debug( "* Manage Account ID: #{params[:id]}" )
    @account_id = params[:id]
    account = Account.find_by_id( @account_id )
    redirect_to( accounts_path() ) and return unless account

    @account_name = account.name
    @default_currency_id_for_account_rows = account.get_default_currency_id()
                                                    # Compute the filtering parameters:
    ap = AppParameter.get_parameter_row_for( :accounts )
    @max_view_height = ap.get_view_height()
                                                    # Having the parameters, apply the resolution and the radius backwards:
    start_date = DateTime.now.strftime( ap.get_filtering_resolution )
                                                    # Set the (default) parameters for the scope configuration: (actual used value will be stored inside component_session[])
    @filtering_date_start  = ( Date.parse( start_date ) - ap.get_filtering_radius ).strftime( AGEX_FILTER_DATE_FORMAT_SQL )
    @filtering_date_end    = ( Date.parse( start_date ) + ap.get_filtering_radius ).strftime( AGEX_FILTER_DATE_FORMAT_SQL )
  end
  # ---------------------------------------------------------------------------


  # Outputs a detailed report containing both the Account header and the selected rows,
  # specified with an array of AccountRow IDs.
  #
  # == Params:
  #
  # - <tt>:type</tt> => the extension of the file to be created; one among: 'pdf', 'odt', 'txt', 'full.csv', 'simple.csv'
  #   (default: 'pdf')
  #
  # - <tt>:data</tt> (*required*) => a JSON-encoded array of AccountRow IDs to be retrieved and processed
  #
  # - <tt>:date_from_lookup</tt> / <tt>:date_to_lookup</tt> => 
  #   String dates representing the starting and ending filter range for this collection of rows.
  #   Both are not required (none, one or both can be supplied as options).
  #
  # - <tt>:separator</tt> => text separator used only for data export; default: ';'
  #
  # - <tt>:layout</tt> => either 'full' [default] or 'nostats', to specify the export data layout used
  #   (both usable for CSV and TXT output files)
  #
  def report_detail
#    logger.debug "\r\n!! ----- report_detail -----"
#    logger.debug "report_detail: params #{params.inspect}"
                                                    # Parse params:
    id_list = ActiveSupport::JSON.decode( params[:data] ) if params[:data]
    unless id_list.kind_of?(Array)
      raise ArgumentError, "accounts_controller.report_detail(): invalid or missing data parameter!", caller
    end
    return if id_list.size < 1
                                                    # Retrieve the rows from the ID list:
    records = nil
    begin
      records = AccountRow.where( :id => id_list )
    rescue
      raise ArgumentError, "accounts_controller.report_detail(): no valid ID(s) found inside data parameter!", caller
    end
# DEBUG
#    logger.debug "accounts_controller.report_detail(): id list: #{id_list.inspect}"
    return if records.nil?
#    logger.debug "accounts_controller.report_detail(): records class: #{records.class}"
#    logger.debug "accounts_controller.report_detail(): records found: #{records.size}"

    filetype    = params[:type] || 'pdf'
    separator   = params[:separator] || ';'         # (This plus the following params are used only during data exports)
    use_layout  = (params[:layout].nil? || params[:layout].empty?) ? :full : params[:layout].to_sym
    skip_header = (params[:no_header] == 'true' || params[:no_header] == '1')
                                                    # Obtain header row:
    record = records[0]
    if record.kind_of?( ActiveRecord::Base )        # == Init LABELS ==
      label_hash = {}                               # Initialize hash and extract all details column labels:
      header_record = Account.find( record.account_id )
      (                                             # Extract all possible report labels: (only if not already present)
        header_record.serializable_hash.keys +
        record.serializable_hash.keys +
        Account.report_label_symbols() +
        Account.report_header_symbols() +
        AccountRow.report_detail_symbols()
      ).each { |e|
        label_hash[e.to_sym] = I18n.t( e.to_sym, {:scope=>[:account_row]} ) unless label_hash[e.to_sym]
      }

                                                    # == DATA Collection == (Data must be converted under a common currency)
      report_data_hash = prepare_report_data_hash(
          header_record,
          records,
          label_hash,
          {
            :rjustification      => (filetype =~ /txt/) != nil         ? 15 : 0,
            :date_from_lookup    => params[:date_from_lookup].to_s.gsub(/\'/,''),
            :date_to_lookup      => params[:date_to_lookup].to_s.gsub(/\'/,''),
            :do_float_formatting => (filetype =~ /txt|pdf|odt/) != nil ?  1 : nil
          }
      )


      label_hash = report_data_hash[:label_hash]    # Retrieve the updated label_hash
      currency = report_data_hash[:currency_short]  # (Use report_data_hash[:currency_name].titleize if the PDF default font does not support the special currency symbols)
      AccountRow::CURRENCY_SYMS.each { |e|          # Add verbose currency display to column title:
        label_hash[e.to_sym] = "#{label_hash[e.to_sym]} (#{currency})"
      }

                                                    # == OPTIONS setup + RENDERING phase ==
      filename = create_unique_filename( report_data_hash[:report_base_name] ) + ".#{filetype}"


      if ( filetype == 'pdf' )                      # --- PDF ---
        options = {
          :date_from           => params[:date_from_lookup].to_s.gsub(/\'/,''),
          :date_to             => params[:date_to_lookup].to_s.gsub(/\'/,'')
        }.merge!( report_data_hash ).merge!(
          header_record.prepare_report_header_hash()
        )
                                                    # == Render layout & send data:
        send_data(
            AccountRowLayout.render( options ),
            :type => 'application/pdf',
            :filename => filename
        )
        # -------------------------------------------


      elsif ( filetype == 'odt' )                   # --- ODT ---
        filename = "public/output/#{filename}"
        options = {
          # For documatic report output, the following terms are the only ones that count; the others
          # could either be stored in :options or in :data for the process template:
          # (Note how the template file depends upon the currently set locale)
          :template_file    => "lib/odt_layouts/account_#{I18n.locale}.odt",
          :output_file      => filename,
          :current_datetime => DateTime.now.strftime("[%Y-%m-%d, %H:%M:%S]")
        }.merge!( header_record.prepare_report_header_hash() )
                                                    # == Render layout & send data:
        Documatic::OpenDocumentText::Template.process_template(
            :options => Ruport::Controller::Options.new( options ),
            :data => report_data_hash
        )
        logger.info( "[I!]-- Created documatic Account report '#{filename}'." )
        FileUtils.chmod( 0644, filename )
        send_file( filename )                       # send the generated file to the outside world
        # -------------------------------------------

                                                    # --- TXT & DATA EXPORT formats ---
      else
        data = prepare_custom_export_data(
            report_data_hash.merge!( header_record.prepare_report_header_hash() ),
            filetype,
            separator,
            use_layout,
            skip_header
        )
# DEBUG
#        puts data
        send_data( data, :type => "text/#{filetype}", :filename => filename )
        # -------------------------------------------
      end
    end
  end
  # ---------------------------------------------------------------------------
  # ---------------------------------------------------------------------------


  # Destroys an existing Data-import session
  #
  def kill_data_import_session
    destroy_data_import_session( params[:id].to_i ) if params[:id]
    redirect_to( data_import_accounts_path() )
  end


  # Accounts Data Import Wizard: START
  # Phase #1: upload text (CSV) file / Select an existing Data-import session
  #
  def data_import                                   # Retrieve current sessions for the current user and list them:
    @existing_import_sessions = AccountDataImportSession.where(:user_id => current_user.id)
  end


  # Accounts Data Import Wizard: Phase#2 (file parsing & consequent manual review of the data)
  # Scan each data-import row and parse it, preparing its "preview" columns.
  #
  # == Params:
  #
  # - <tt>:id</tt> => id of the  data-import session in progress; when present, takes precedence over the +datafile+ parameter
  # - <tt>:datafile</tt> => an uploaded datafile (an ActionDispatch::Http::UploadedFile object)
  #
  def data_import_wizard
# DEBUG
#    logger.debug "\r\n\r\n!! ------ in data_import_wizard -----"
#    logger.debug "PARAMS: #{params.inspect}"
#    logger.debug "FILENAME: #{params[:datafile].original_filename if params[:datafile]}"
#    logger.debug "\r\n!! ===========================\r\n"
    data_import_session = nil

    if params[:id]                                  # :id parameter present? We then assume a session is already in progress:
      data_import_session = AccountDataImportSession.find_by_id( params[:id].to_i )

    elsif params[:datafile]                         # :datafile parameter present? Copy the file to its destination:
      tmp_file = params[:datafile].tempfile         # (This is an ActionDispatch::Http::UploadedFile object)
      destination_filename = File.join( "public/uploads", params[:datafile].original_filename )
      FileUtils.cp tmp_file.path, destination_filename
                                                    # Create a new data-import session and consume the file:
      data_import_session = consume_csv_file( destination_filename )
    end
                                                    # Session retrieval successful? Head on to phase #2 and let the component handle the rest:
    @account_data_import_session_id = data_import_session ? data_import_session.id : nil
                                                    # Compute the filtering parameters:
    ap = AppParameter.get_parameter_row_for( :accounts )
    @max_view_height = ap.get_view_height()
  end


  # Accounts Data Import Wizard: phase #3 (Phase #2 is manual review of the parsed data)
  # On editable data grid final commit, do the actual data import into destination table,
  # logging every error or mismatch and finally displaying it on the dedicated view.
  #
  # == Params:
  #
  # - <tt>:data</tt> => a JSON-encoded array of AccountDataImportRow IDs to be retrieved and processed
  #
  def data_import_commit
#    logger.debug "\r\n!! ----- data_import_commit -----"
#    logger.debug "data_import_commit: params #{params.inspect}"
                                                    # Parse params:
    id_list = ActiveSupport::JSON.decode( params[:data] ) if params[:data]
    unless id_list.kind_of?(Array)
      raise ArgumentError, "accounts_controller.data_import_commit(): invalid or missing data parameter!", caller
    end
    return if id_list.size < 1
                                                    # Retrieve the account rows from the ID list:
    records = nil
    begin
      records = AccountDataImportRow.where( :id => id_list )
    rescue
      raise ArgumentError, "accounts_controller.data_import_commit(): no valid ID(s) found inside data parameter!", caller
    end
# DEBUG
#    logger.debug "accounts_controller.data_import_commit(): id list: #{id_list.inspect}"
                                                    # Build up the full log, keeping each phase separated:
    @import_log = "--------------------[Phase #1]--------------------\r\n"
    phase_2_log = "\r\nImporting data @ #{Format.a_short_datetime(DateTime.now)}:...\r\n"
    data_import_session = nil
    data_import_row_skipped = 0
    curr_row = 0

    if ( records.size() > 0 )
      data_import_session = AccountDataImportSession.find_by_id( records[0].account_data_import_session_id )
                                                    # For each data import row id sent as params, do an AccountRow.create()
      records.each { |data_import_row|
        is_ok = false
                                                    # Make sure data_import_row is of the right kind, otherwise, log the error:
        if ( data_import_row ).kind_of?( AccountDataImportRow )
          account_row = AccountRow.new()
          begin
            account_row.account_id                    = data_import_row.account_id
            account_row.date_entry                    = data_import_row.date_entry
            account_row.entry_value                   = data_import_row.entry_value
            account_row.description                   = data_import_row.description
            account_row.le_currency_id                = data_import_row.le_currency_id
            account_row.recipient_firm_id             = data_import_row.recipient_firm_id
            account_row.parent_le_account_row_type_id = data_import_row.parent_le_account_row_type_id
            account_row.le_account_row_type_id        = data_import_row.le_account_row_type_id
            account_row.le_account_payment_type_id    = data_import_row.le_account_payment_type_id
            account_row.check_number                  = data_import_row.check_number
            account_row.user_id                       = data_import_row.user_id
            account_row.notes                         = data_import_row.notes
            account_row.save!                       # raise automatically an exception if save is not successful
                                                    # Update the phase-2 log:
            phase_2_log << "#{curr_row}) data_import_row ID=#{data_import_row.id} => account_row ID=#{account_row.id} (#{Format.a_date(account_row.date_entry)}, #{account_row.entry_value})... "
            is_ok = true
          rescue
            log_error("accounts_controller.data_import_commit(): error during save! Row (# #{curr_row}) data_import_row ID=#{data_import_row.id} skipped.");
            data_import_row_skipped += 1
          end
        else
            log_error("accounts_controller.data_import_commit(): wrong row class type (class=#{data_import_row.class.name}). Row (# #{curr_row}) data_import_row ID=#{data_import_row.id} skipped.");
            data_import_row_skipped += 1
        end
                                                    # After each successful create(), delete data-import source row:
        if ( is_ok )
# DEBUG
#          logger.debug "accounts_controller.data_import_commit(): row imported; deleting data-import row ID:#{data_import_row.id}..."
          AccountDataImportRow.delete( data_import_row.id )
          phase_2_log << "Row consumed.\r\n"
        end
        curr_row += 1
      }
    end
                                                    # Update the log:
    phase_2_log << "\r\nDone.\r\nSkipped rows: #{data_import_row_skipped}/#{curr_row}\r\n"
    @import_log += ( data_import_session ? data_import_session.phase_1_log : '(master data-import session missing)' ) +
                   "\r\n\r\n--------------------[Phase #2]--------------------\r\n#{phase_2_log}"
                                                    # Only if everything was successful, delete also the master data-import session row:
    if ( data_import_session && data_import_row_skipped < 1 )
# DEBUG
      logger.debug "accounts_controller.data_import_commit(): everything was imported... Removing also master data-import session row ID:#{data_import_session.id}"
      destroy_data_import_session( data_import_session.id )
                                                    # Something was skipped? Update the log inside the DB:
    else
      if ( data_import_session )
        data_import_session.phase = 2
        data_import_session.phase_2_log = phase_2_log
        data_import_session.save
      else                                          # A session master record should always be present at this point:
        log_error( "accounts_controller.data_import_commit(): Warning: data-import session with id=#{data_import_session.id} was missing or already deleted." )
      end
    end

    @import_log += "==================================================\r\n"
  end
  # ---------------------------------------------------------------------------
  # ---------------------------------------------------------------------------


  private


  # Prepares the hash of data that will be used for report layout formatting.
  #
  # === Parameters:
  # - <tt>header_record</tt> =>
  #   Header (or parent entity) row associated with the current Model instance
  #
  # - <tt>records</tt> =>
  #   an ActiveRecord::Relation result to be processed as the main dataset
  #
  # - <tt>label_hash</tt> =>
  #   Hash container for all the text labels and strings that have been localized and are ready to be used  
  #
  # === Additional options: (inside +options+ hash)
  # - <tt>:rjustification</tt> => numbers of blank fillers to be used for fixed-width floats;
  #   this is useful actually only for text file formatting, for PDF files ignore this option
  #   (justification is column based and layout-specific). Defaults to 0.
  #
  # - <tt>:date_from_lookup</tt> => filtering date range start
  #
  # - <tt>:date_to_lookup</tt> => filtering date range end
  #
  # - <tt>:do_float_formatting</tt> => set this != nil to convert to text and enforce a fixed text format for each float value
  #
  def prepare_report_data_hash( header_record, records, label_hash, options = {} )
    unless records.kind_of?( ActiveRecord::Relation )
      raise ArgumentError, "accounts_controller.prepare_report_data_hash(): invalid records parameter!", caller
    end
    unless header_record.kind_of?( ActiveRecord::Base )
      raise ArgumentError, "accounts_controller.prepare_report_data_hash(): invalid header_record parameter!", caller
    end
                                                    # == CURRENCY == Store currency name for later usage:
    currency_name  = header_record.get_currency_name
    currency_short = header_record.get_currency_symbol
                                                    # == DATA COLLECTION == Detail data table + summary:
    # First, compute summary sum via SQL mainly to get just the grand total, using the main
    # list of records:
    computed_sums = AccountRow.prepare_summary_hash(
        :records => records,
        :date_from_lookup => options[:date_from_lookup],
        :date_to_lookup => options[:date_to_lookup],
        :do_float_formatting => options[:do_float_formatting]
    )
                                                    # Add the computed sums keys to the label hash:
    computed_sums.keys.each { |key|
      label_hash[ key ] = I18n.t( key, {:scope=>[:account_row]} )
    }
    grouping_total = computed_sums[:grand_total].to_s

    data_table = AccountRow.prepare_report_detail(  # Build the data set into Ruport's Table class
        :records => records,
        :date_from_lookup => options[:date_from_lookup],
        :date_to_lookup => options[:date_to_lookup],
        :computed_sums => computed_sums,
        :currency_name => currency_name,
        :rjustification => options[:rjustification].to_i
    )
    summary_rows = [[
        label_hash[:grouping_totals_label],
        currency_name
      ]] + computed_sums[:subtotal_order].collect{ |i|
      [
        computed_sums[:subtotal_names][i],
        computed_sums[:subtotal_values][i]
      ]
    }

    result_hash = {                                 # Prepare result hash:
      :report_title     => header_record.get_title_names().join(" - "),
      :report_base_name => header_record.get_base_name(),
                                                    # Main data:
      :data_table       => data_table,
      :date_from        => options[:date_from_lookup],
      :date_to          => options[:date_to_lookup],

      :summary          => computed_sums,           # Stats / Items summary
      :summary_rows     => summary_rows,            # Array of rows for the summary table rendered by sprawn on PDF
      :label_hash       => label_hash,              # (This should be already translated and containing all the required label symbols)
      :currency_name    => currency_name,
      :currency_short   => currency_short,          # (currency display symbol or short name)
      :grouping_total   => grouping_total
    }

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
  # - <tt>:data_table</tt> => <tt>Ruport::Data::Table</tt> instance containing the data rows to be processed.
  # - <tt>:summary</tt> => hash of values as returned by <tt>prepare_summary_hash()</tt>.
  #
  #
  def prepare_custom_export_data( report_data_hash, filetype = 'txt', separator = ';',
                                  use_layout = :full, skip_header = false )
    data = ''
                                                    # Check all supported layouts:
    if use_layout.to_sym == :full || use_layout.to_sym == :no_stats
                                                    # --- REPORT HEADER: ---
      Account.report_header_symbols().each { |key|
        data << I18n.t( key, {:scope=>[:account_row]} )
        data << "#{separator} #{report_data_hash[key]}\r\n"
      }
                                                    # Localize column names:
      localize_ruport_table_column_names( report_data_hash[:data_table], :account_row, report_data_hash[:label_hash] )
                                                    # --- DATA ---
      if ( filetype =~ /csv/ )
        data << report_data_hash[:data_table].as( :csv, :format_options => {:col_sep => separator}, :ignore_table_width => true )
      else
        data << report_data_hash[:data_table].as( :text, :ignore_table_width => true, :alignment => :rjust )
      end
      data << "\r\n"

      unless use_layout.to_sym == :no_stats         # --- ENDING SUMMARY: --- (Uses fixed width for floats)
        data << "\r\n#{I18n.t(:grouping_totals_label, {:scope=>[:account_row]} ).upcase}:\r\n"
        summary_hash = report_data_hash[:summary]
        summary_hash[:subtotal_values].each { |key, val|
          data << "#{summary_hash[:subtotal_names][key]}#{separator}#{val}\r\n"
        }
      end

    else                                            # == Any unsupported layout specified? ==
      # TODO ":flat" layout type (with no header) not needed yet
      data = "\r\n-- Unsupported layout format '#{use_layout}' specified! --\r\n\r\n"
    end

    data
  end
  # ---------------------------------------------------------------------------
  # ---------------------------------------------------------------------------


  # Data-import Phase #1: CSV storage and "consumption".
  #
  # Reads the whole CSV file into memory, assuming <tt>csv_separator</tt>
  # as column separator, while actually processing data starting from row number <tt>data_rows_starting_at</tt>.
  #
  # A new data-import session is then created while also adding each data row to the
  # temporary data-import rows table.
  #
  # When all the data is transferred to the temporary tables, the file is consumed (killed)
  # from the upload directory.
  #
  # The "Phase #2" of the "data-import wizard" it can subsequently begin.
  #
  # === Returns the newly created "data_import" session instancif successful
  #
  def consume_csv_file( full_pathname, csv_separator = ';', data_rows_starting_at = 1 )
# DEBUG
#    logger.debug( "\r\n-- consume_csv_file(#{full_pathname}):" )
    full_text_file_contents = ""
    phase_1_log = ""
    data_rows = []
    stored_data_rows = 0
    line_count = 0
                                                    # Scan each line of the file until gets reaches EOF:
    File.open( full_pathname ) do |f|
      f.each_line { |curr_line|
        full_text_file_contents << curr_line
                                                    # Split each line into an array of fields:
        data_row = curr_line.delete('"').strip.split( csv_separator )
        data_rows << data_row if line_count >= data_rows_starting_at
# DEBUG
#        logger.debug( "Processing line #{line_count}... #{data_row.size} columns/fields." )
        
        line_count += 1                             # Increase total number of read rows
      }
    end                                             # (automatically closes the file)

                                                    # Store the raw text file into its row header
    data_import_session = create_new_data_import_session(
        full_pathname,
        full_text_file_contents,
        data_rows.size,
        'bper'                                      # FIXME Pre-fixed file structure type, only BPER supported, no parsing at all
    )

    if ( data_import_session )          # Create also all the data-import rows from the source text file:
      data_rows.each_with_index { |array_of_column_values, index|
# DEBUG
#        logger.debug( "Adding BPER data row #{index}/#{data_rows.size}: #{array_of_column_values.inspect}" )
                                                    # Store each row into the dedicated temp DB table:
        stored_data_rows += add_new_import_row_for_data_structure_bper( data_import_session.id, array_of_column_values )
      }
                                                    # After successfully store the contents, remove the file
# DEBUG
#      logger.debug( "-- consume_csv_file(#{full_pathname}): file processed. Consuming it...\r\n" )
      FileUtils.rm( full_pathname )
                                                    # Update current phase indicator & log:
      data_import_session.phase = 1
      phase_1_log << "\r\nFile '#{File.basename( full_pathname )}', created session ID: #{data_import_session.id}\r\nTotal file lines ....... : #{line_count}\r\nTotal data lines ....... : #{data_rows.size}\r\nActual stored rows ..... : #{stored_data_rows}\r\nFile processed.\r\n"
      data_import_session.phase_1_log = phase_1_log
      data_import_session.save
# DEBUG
#      logger.debug( "-- consume_csv_file(#{full_pathname}): data-import PHASE #1 DONE.\r\n" )

    else
      log_error( "consume_csv_file(#{full_pathname}): failed to create a new data-import session!" )
    end

    logger.debug( "-- consume_csv_file(#{full_pathname}):\r\n" )
    logger.debug( phase_1_log )

    return data_import_session
  end
  # -----------------------------------------------------------------------------


  # Creates a new data-import session returning its instance.
  #
  def create_new_data_import_session( full_pathname, full_text_file_contents, total_data_rows, file_format )
    AccountDataImportSession.create(
      :file_name => full_pathname,
      :source_data => full_text_file_contents,
      :user_id => current_user().id,
      :total_data_rows => total_data_rows,
      :file_format => file_format
    )
  end


  # Destroys an existing Data-import session: implementation
  #
  def destroy_data_import_session( session_id )
    data_import_session = AccountDataImportSession.find_by_id( session_id )

    if ( data_import_session )                      # For a safety clean-up, check also if the file wasn't consumed properly after phase-1:
      full_pathname = File.join(Dir.pwd, data_import_session.file_name)
      if ( FileTest.exists?(full_pathname) )
        logger.info( "-- destroy_data_import_session(#{session_id}): the import file wasn't consumed properly after phase-1. Erasing it..." )
        FileUtils.rm( full_pathname )
      end
      AccountDataImportSession.delete( session_id )
      AccountDataImportRow.delete_all( :account_data_import_session_id => session_id )
      logger.info( "-- destroy_data_import_session(#{session_id}): data-import session clean-up done.\r\n" )
    else
      logger.info( "-- destroy_data_import_session(#{session_id}): warning: unable to find the specified data-import session master record.\r\n" )
    end
  end


  # Creates a new temporary data-import row on the DB.
  # Returns the number of data rows stored (1 in case of no errors)
  #
  def add_new_import_row_for_data_structure_bper( data_import_session_id, array_of_column_values )
                                                    # Bail out if there's nothing to do:
    return 0 if ( array_of_column_values.kind_of?( Array ) && array_of_column_values.size == 0 )
                                                    # Throw an exception only in case of "type error":
    unless ( array_of_column_values.kind_of?( Array ) && array_of_column_values.size >= 7 )
      raise ArgumentError, "accounts_controller.add_new_import_row_for_data_structure_bper(): invalid 'array_of_column_values' parameter!", caller
    end
                                                    # Custom data conversions:
    float_value = 0.0
    date_account = nil
    date_currency = nil
    begin                                           # Convert _from_ the text format used inside the data file:
      float_value   = array_of_column_values[4].to_f
      date_account  = DateTime.strptime( array_of_column_values[2], '%d/%m/%Y' )
      date_currency = DateTime.strptime( array_of_column_values[3], '%d/%m/%Y' )
    rescue
    end

    # Phase 1.1) detect which account_id
    account_id = detect_which_account_id( array_of_column_values )

    # Phase 1.2) forcibly set current_user as user_id, text_2 as notes
    user_id = current_user.id
    notes = ( array_of_column_values.size > 7 ? array_of_column_values[7] : nil )

    # Phase 1.3) detect which le_currency_id
    le_currency_id = detect_which_currency_id( array_of_column_values )

    # Phase 1.4) detect which parent_le_account_row_type_id
    parent_le_account_row_type_id = detect_which_parent_le_account_row_type_id( array_of_column_values )

    # Phase 1.5) detect which le_account_row_type_id
    le_account_row_type_id = detect_which_le_account_row_type_id( array_of_column_values )

    # Phase 1.6) detect which le_account_payment_type_id
    le_account_payment_type_id = detect_which_le_account_payment_type_id( array_of_column_values )

    # Phase 1.7) detect which check_number, when appropriate
    check_number = detect_which_check_number( array_of_column_values )

    # Phase 1.8) detect which recipient_firm_id, when possible
    recipient_firm_id = detect_which_recipient_firm_id( array_of_column_values )

    # Phase 1.9) detect which description, when possible; else use the text_1
    description = detect_which_description( array_of_column_values )

    # Phase 1.10) detect which conflicting_account_row_id, using as info/search key: mainly date_currency(I) || date_account(II) && float_value, + the above info
    conflicting_account_row_id = detect_which_conflicting_account_row_id( account_id, float_value, date_account, date_currency )

                                                    # Store the data row:
    AccountDataImportRow.create(
      :account_data_import_session_id => data_import_session_id,
                                                    # -- Original import data: --
      :string_1 => array_of_column_values[1],       # Account number
      :date_1   => date_account,                    # Entry Date
      :date_2   => date_currency,                   # Currency Date
      :float_1  => float_value,                     # Entry value
      :string_2 => array_of_column_values[5],       # Currency symbol ('EUR'='euro', 'DOL'='dollar', ...)
      :text_1   => array_of_column_values[6],       # Original/source text
                                                    # Hand Notes: (may be null and thus not split from original source text)
      :text_2   => notes,
                                                    # -- Parsed import data: --
      :conflicting_account_row_id => conflicting_account_row_id,
      :account_id   => account_id,
      :date_entry   => date_currency,               # (as is)
      :entry_value  => float_value,                 # (as is)
      :description  => description,
      :le_currency_id     => le_currency_id,
      :recipient_firm_id  => recipient_firm_id,
      :parent_le_account_row_type_id  => parent_le_account_row_type_id,
      :le_account_row_type_id         => le_account_row_type_id,
      :le_account_payment_type_id     => le_account_payment_type_id,
      :check_number => check_number,
      :user_id      => user_id,
      :notes        => notes
    )
    return 1
  end
  # ---------------------------------------------------------------------------


  # Data-import (sub-) Phase 1.1
  #
  def detect_which_account_id( array_of_column_values )
    if array_of_column_values[1] == '00001654466'
      begin
        return Account.where( :name => 'comune' ).first.id
      rescue
        return nil
      end

    elsif array_of_column_values[1] == '00000906683'
      begin
        return Account.where( :name => 'pagamenti' ).first.id
      rescue
        return nil
      end

    elsif array_of_column_values[1] == '00000004745'
      begin
        return Account.where( :name => 'personale' ).first.id
      rescue
        return nil
      end
    else
      nil
    end
  end


  # Data-import (sub-) Phase 1.3
  #
  def detect_which_currency_id( array_of_column_values )
    if array_of_column_values[5] == 'EUR'
      return LeCurrency.where( :name => 'euro' ).first.id
    elsif array_of_column_values[5] == 'USD'
      return LeCurrency.where( :name => 'US Dol.' ).first.id
    else
      nil
    end
  end


  # Data-import (sub-) Phase 1.4
  #
  def detect_which_parent_le_account_row_type_id( array_of_column_values )
    # Possible parent categories:
    # costi, interessi, profitti, imposte e tasse, investimenti, rimborsi, prelievi,
    # integrazione cassa, disinvestimenti, stipendi dip., rimborsi al titolare,
    # prelievi del titolare
    case array_of_column_values[6]
                                                    # "imposte e tasse"
    when /IMPOSTA|MODELLO UNICO|ADDEBITO RID CONSORZIO BONIFICA/
      return LeAccountRowType.where( :name => 'imposte e tasse' ).first.id
                                                    # "costi"
    when /DISPOSIZIONE A|ADDEBITO RID|TELECOM|IREN |ENEL SPA|PAGAMENTO|COMMISSIONI|COMPETENZE|CONAD|PAGOBANCOMAT/
      return LeAccountRowType.where( :name => 'costi' ).first.id
                                                    # "profitti"
    when /BONIFICO/
      return LeAccountRowType.where( :name => 'profitti' ).first.id
                                                    # "integrazione cassa"
    when /VERSAMENTO|ASSEGNI/
      return LeAccountRowType.where( :name => 'integrazione cassa' ).first.id
                                                    # "investimenti"
    when /FONDI SICAV|TITOLI SOTTOSCRIZ/
      return LeAccountRowType.where( :name => 'investimenti' ).first.id
                                                    # "interessi"
    when /CEDOLE/
      return LeAccountRowType.where( :name => 'interessi' ).first.id
                                                    # "disinvestimenti"
    when /RIMB\.TITOLI/
      return LeAccountRowType.where( :name => 'disinvestimenti' ).first.id
                                                    # "prelievi del titolare"
    when /PRELEVAMENTO|PRELIEVO/
      return LeAccountRowType.where( :name => 'prelievi del titolare' ).first.id
      
    else
      nil
    end
  end


  # Data-import (sub-) Phase 1.5
  #
  def detect_which_le_account_row_type_id( array_of_column_values )
    # Possible categories:
    # "RC auto", "abbigliamento", "alimentari", "alimentari / biologico", "altre spese di trasferta",
    # "anticipo del titolare", "autostrada", "autoveicoli", "benzina", "biblioteca",
    # "biglietti di viaggio", "entrate Baby", "entrate Steve", "fatturazione", "hardware vario",
    # "manutenzione auto", "manutenzione casa", "materiale ufficio", "pranzi / cene fuori",
    # "riviste di settore", "sanitari", "servizi bancari", "servizi xDSL", "software vario",
    # "spese condominiali", "suppellettili", "telefono", "utenze servizi", "varie" 
    case array_of_column_values[6]
    when /TELECOM ITALIA UTENZA/
      return LeAccountRowType.where( :name => 'telefono' ).first.id
    when /PAGAMENTO UTENZE WIND - INFOSTRADA/
      return LeAccountRowType.where( :name => 'servizi xDSL' ).first.id
    when /IREN |ENEL SPA|PAGAMENTO UTENZE/
      return LeAccountRowType.where( :name => 'utenze servizi' ).first.id
    when /ADDEBITO RID CONSORZIO BONIFICA/
      return LeAccountRowType.where( :name => 'varie' ).first.id
    when /COMMISSIONI|COMPETENZE|IMPOSTA DI BOLLO/
      return LeAccountRowType.where( :name => 'servizi bancari' ).first.id

    when /BONIFICO O\/C SESENA BARBARA/
      return LeAccountRowType.where( :name => 'entrate Baby' ).first.id
    when /VERSAMENTO|VERSAM\. ASSEGN|BONIFICO DA CC 4745/
      return LeAccountRowType.where( :name => 'entrate Steve' ).first.id

    when /IMPOSTA DI BOLLO|COMPETENZE/
      return LeAccountRowType.where( :name => 'servizi bancari' ).first.id
                                                    # "CONGUAGLIO IMPOSTA"
    when /MODELLO UNICO|IMPOSTA/
      return LeAccountRowType.where( :name => 'varie' ).first.id

    when /SUPERMERCATO|CONAD|IPERCOOP|IPERAFFI/
      return LeAccountRowType.where( :name => 'alimentari' ).first.id
    when /ARES S\.R\.L|COSEBIO DI COSETTA/
      return LeAccountRowType.where( :name => 'alimentari / biologico' ).first.id
    when /SHELL|AGIP/
      return LeAccountRowType.where( :name => 'benzina' ).first.id

    when /COMPLESSO CONDOMINIALE NOVE/
      return LeAccountRowType.where( :name => 'spese condominiali' ).first.id

    else
      return LeAccountRowType.where( :name => 'varie' ).first.id
    end
  end


  # Data-import (sub-) Phase 1.6
  #
  def detect_which_le_account_payment_type_id( array_of_column_values )
    # Possible categories:
    # "contanti", "carta di credito", "bancomat", "assegno", "bonifico bancario", "addebito su c.c.",
    # "accredito su c.c."
    case array_of_column_values[6]                  # "bonifico bancario"
    when /BONIFICO/
      return LeAccountPaymentType.where( :name => 'bonifico bancario' ).first.id
                                                   # "addebito"
    when /IMPOSTA|MODELLO UNICO|ADDEBITO RID|DISPOSIZIONE|PAGAMENTO UTENZE|COMMISSIONI|COMPETENZE|TELECOM|IREN |ENEL SPA/
      return LeAccountPaymentType.where( :name => 'addebito su c.c.' ).first.id
                                                    # "bancomat"
    when /PAGOBANCOMAT/
      return LeAccountPaymentType.where( :name => 'bancomat' ).first.id
                                                    # "carta di credito"
    when /CONAD|PAGOBANCOMAT|PAGAMENTO SU CIRCUITO INTERNAZIONALE|CARTA DI CREDITO/
      return LeAccountPaymentType.where( :name => 'carta di credito' ).first.id
                                                    # "assegno"
    when /ASSEGNO|VERSAM\. ASSEGN/
      return LeAccountPaymentType.where( :name => 'assegno' ).first.id
                                                    # "contanti"
    when /VERSAMENTO/
      return LeAccountPaymentType.where( :name => 'contanti' ).first.id
    else
      nil
    end
  end


  # Data-import (sub-) Phase 1.7
  #
  def detect_which_check_number( array_of_column_values )
    # TODO Extract from description (Missing a valid data sample to try it out)
    ''
  end


  # Data-import (sub-) Phase 1.8
  #
  def detect_which_recipient_firm_id( array_of_column_values )
    case array_of_column_values[6]                  # "bonifico bancario"
    when /PEDRONI/
      begin
        return Firm.where( :name => 'Marco Pedroni' ).first.id
      rescue
        return nil
      end
    when /FASAR/
      begin
        return Firm.where( :name => 'FASAR Software di Stefano Alloro' ).first.id
      rescue
        return nil
      end
    else
      nil
    end
  end


  # Data-import (sub-) Phase 1.9
  #
  def detect_which_description( array_of_column_values )
    case array_of_column_values[6]
    when /TELECOM ITALIA UTENZA/
      return 'utenza Telecom Italia'
    when /WIND|ALICE/
      return 'utenza servizio ADSL'
    when /GAS/
      return 'utenza servizio gas'
    when /ACQUA|IDRICO/
      return 'utenza servizio idrico'
    when /RIFIUTI/
      return 'utenza servizio rifiuti'
    when /LUCE|ELETTRI|ENEL/
      return 'utenza servizio elettrico'
    when /CONSORZIO BONIFICA|BONIFICA EMILIA/
      return 'tassa consorzio di bonifica'
    when /COMMISSIONI/
      return 'commissioni bancarie'
    when /COMPETENZE/
      return 'competenze bancarie'
    when /IMPOSTA DI BOLLO/
      return 'imposta di bollo'
    when /MODELLO UNICO/
      return 'pagamento modello Unico'

    when /BONIFICO O\/C SESENA BARBARA|BONIFICO DA CC 4745/
      return 'bonifico per integrazione cassa'
    when /VERSAMENTO|VERSAM. ASSEGN/
      return 'integrazione cassa'

    when /CONADCARD|CONAD CARD/
      return 'spese alimentari su Conad Card a fine mese'
    when /IPERCOOP/
      return 'spese alimentari / varie c/o IperCoop'
    when /IPERAFFI/
      return 'spese alimentari c/o IperAffi'
    when /SUPERMERCATO|CONAD/
      return 'spese alimentari / varie con Bancomat'
    when /ARES S\.R\.L|COSEBIO DI COSETTA/
      return 'spese alimentari c/o supermerc. biologico'
    when /SHELL|AGIP/
      return 'benzina'

    when /COMPLESSO CONDOMINIALE NOVE/
      return 'rata spese condominiali'

    else
      return array_of_column_values[6].gsub(/PAGOBANCOMAT /i,'').titleize()
    end
  end


  # Data-import (sub-) Phase 1.10
  #
  def detect_which_conflicting_account_row_id( account_id, float_value, date_account, date_currency )
    date_from = date_to = nil                       # Adjust date_from / date_to:
    if ( date_account <= date_currency )
      date_from = date_account
      date_to   = date_currency
    else
      date_to   = date_account
      date_from = date_currency
    end
                                                    # Retrieve the existing tuples like [account_id, float_value, date_account, date_currency]:
    records = AccountRow.where(
      'account_id = :account_id AND entry_value = :entry_value AND (date_entry >= :date_from AND date_entry <= :date_to)',
      { :account_id => account_id,
        :entry_value => float_value,
        :date_from => date_from,
        :date_to => date_to
      }
    )
                                                    # Return the first among the tuples found:    
    ( records.size > 0 ? records.first.id : nil )
  end
  # ---------------------------------------------------------------------------
  # ---------------------------------------------------------------------------

end
