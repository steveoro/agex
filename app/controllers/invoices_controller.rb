# encoding: utf-8

class InvoicesController < ApplicationController
  require 'common/format'
  require 'ruport'
  require 'fileutils'                               # Used to process filenames
  require 'invoice_row_layout'
  require 'documatic'


  # Require authorization before invoking any of this controller's actions:
  before_filter :authorize


  # Default action ("/invoices")
  def index
    ap = AppParameter.get_parameter_row_for( :invoices )
    @max_view_height = ap.get_view_height()
                                                    # Having the parameters, apply the resolution and the radius backwards:
    start_date = DateTime.now.strftime( ap.get_filtering_resolution )
                                                    # Set the (default) parameters for the scope configuration: (actual used value will be stored inside component_session[])
    @filtering_date_start  = ( Date.parse( start_date ) - ap.get_filtering_radius ).strftime( AGEX_FILTER_DATE_FORMAT_SQL )
    @filtering_date_end    = ( Date.parse( start_date ) + ap.get_filtering_radius ).strftime( AGEX_FILTER_DATE_FORMAT_SQL )
  end


  # Invoicing Income Analysis spanning several years
  #
  def analysis
    curr_year  = DateTime.now.strftime( '%Y' ).to_i # Custom resolution and filtering defaults for this action:
    start_year = curr_year - 10
    end_year   = curr_year + 1
                                    # Set the (default) parameters for the scope configuration: (actual used value will be stored inside component_session[])
    @filtering_date_start = Date.parse( "#{start_year}-01-01" ).strftime( AGEX_FILTER_DATE_FORMAT_SQL )
    @filtering_date_end   = Date.parse( "#{end_year}-01-01" ).strftime( AGEX_FILTER_DATE_FORMAT_SQL )
  end


  # Manage a single invoice using +id+ as parameter
  #
  def manage
#    logger.debug( "* Manage Invoice ID: #{params[:id]}" )
    @invoice_id = params[:id]
    invoice = Invoice.find_by_id( @invoice_id )
    redirect_to( invoices_path() ) and return unless invoice

    ap = AppParameter.get_parameter_row_for( :invoices )
    @max_view_height = ap.get_view_height()

    @invoice_name = invoice.name
    @default_currency_id_for_invoice_rows = invoice.get_default_currency_id()
  end
  # ---------------------------------------------------------------------------
  # ---------------------------------------------------------------------------


  # Outputs a detailed report containing both the Invoice header and the selected rows,
  # specified with an array of InvoiceRow IDs.
  #
  # Due to how the Invoices are structured and how they are selected on the detail grid,
  # this method does *not* allow multiple Invoice instances to be printed-out on the
  # same PDF file (in contrary to what happens with the AmbGest application).
  # (To obtain this result a different method, a different Rails route and a different
  # Netzke endpoint should be used.)
  #
  # == Params:
  #
  # - <tt>:type</tt> => the extension of the file to be created; one among: 'pdf', 'odt', 'txt', 'full.csv', 'simple.csv'
  #   (default: 'pdf')
  #
  # - <tt>:data</tt> (required when not using :invoice_id) => a JSON-encoded array of InvoiceRow IDs to be retrieved and processed
  #
  # - <tt>:invoice_id</tt> (required when not using :data) => the ID of the master Invoice to be retrieved and processed
  #
  # - <tt>:is_internal_copy</tt> => when greater than 0, the output is considered as an "internal copy" (not original).
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
    logger.debug "\r\n!! ----- report_detail -----"
    logger.debug "report_detail: params #{params.inspect}"
                                                    # Parse params:
    id_list = ActiveSupport::JSON.decode( params[:data] ) if params[:data]
    invoice_id = params[:invoice_id].to_i if params[:invoice_id]
    unless id_list.kind_of?(Array) || (invoice_id.to_i > 0)
      raise ArgumentError, "invoices_controller.report_detail(): invalid or missing data or invoice_id parameters!", caller
    end
                                                    # Retrieve the invoice rows from the ID list:
    records = nil
    if ( id_list.kind_of?(Array) && id_list.size > 0 )
      begin
        records = InvoiceRow.where( :id => id_list )
      rescue
        raise ArgumentError, "invoices_controller.report_detail(): no valid ID(s) found inside data parameter!", caller
      end
    elsif ( (! invoice_id.nil?) && (invoice_id.to_i > 0) )
      begin
        records = InvoiceRow.where( :invoice_id => invoice_id )
      rescue
        raise ArgumentError, "invoices_controller.report_detail(): no valid InvoiceRow(s) found for invoice_id=#{invoice_id}!", caller
      end
    end
# DEBUG
#    logger.debug "invoices_controller.report_detail(): invoice_id: #{invoice_id.inspect}"
#    logger.debug "invoices_controller.report_detail(): id list: #{id_list.inspect}"
    if ( records.nil? || records == [] )
      flash[:notice] = I18n.t( :invalid_data_or_invoice_with_no_rows, {:scope=>[:invoice_row]} )
      redirect_to( invoices_url() )
    end
#    logger.debug "invoices_controller.report_detail(): records class: #{records.class}"
#    logger.debug "invoices_controller.report_detail(): records found: #{records.size}"

    filetype    = params[:type] || 'pdf'
    separator   = params[:separator] || ';'         # (This plus the following params are used only during data exports)
    use_layout  = (params[:layout].nil? || params[:layout].empty?) ? :tab : params[:layout].to_sym
    skip_header = (params[:no_header] == 'true' || params[:no_header] == '1')
                                                    # Obtain header row:
    record = records[0]
    if record.kind_of?( ActiveRecord::Base )        # == Init LABELS ==
      label_hash = {}                               # Initialize hash and extract all details column labels:
      header_record = Invoice.find( record.invoice_id )
      (                                             # Extract all possible report labels: (only if not already present)
        header_record.serializable_hash.keys +
        record.serializable_hash.keys +
        Invoice.report_label_symbols() +
        Invoice.report_header_symbols() +
        InvoiceRow.report_detail_symbols()
      ).each { |e|
        label_hash[e.to_sym] = I18n.t( e.to_sym, {:scope=>[:invoice_row]} ) unless label_hash[e.to_sym]
      }

                                                    # == DATA Collection == (Data must be converted under a common currency)
      report_data_hash = prepare_report_data_hash(
          header_record,
          records,
          label_hash,
          {
            :rjustification       => (filetype =~ /txt/) != nil         ? 15 : 0,
            :do_float_formatting  => (filetype =~ /txt|pdf|odt/) != nil ?  1 : nil
          }
      )

      label_hash = report_data_hash[:label_hash]    # Retrieve the updated label_hash
      if ( filetype == 'odt' )                      # In preparing for an ODT, use a plain ASCII-8BIT name since Documatic does not handle encodings: 
        currency = report_data_hash[:currency_name].titleize 
      else
        currency = report_data_hash[:currency_short] 
      end
      InvoiceRow::CURRENCY_SYMS.each { |e|          # Add verbose currency display to column title:
        label_hash[e.to_sym] = "#{label_hash[e.to_sym]} (#{currency})"
      }

                                                    # == OPTIONS setup + RENDERING phase ==
      filename = create_unique_filename( report_data_hash[:report_base_name] ) + ".#{filetype}"


      if ( filetype == 'pdf' )                      # --- PDF ---
        options = report_data_hash.merge!(
          header_record.prepare_report_header_hash()
        )
                                                    # == Render layout & send data:
        send_data(
            InvoiceRowLayout.render( options ),
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
          :template_file    => "lib/odt_layouts/invoice_#{I18n.locale}.odt",
          :output_file      => filename,
          :current_datetime => DateTime.now.strftime("[%Y-%m-%d, %H:%M:%S]")
        }.merge!( header_record.prepare_report_header_hash() )
                                                    # == Render layout & send data:
        Documatic::OpenDocumentText::Template.process_template(
            :options => Ruport::Controller::Options.new( options ),
            :data => report_data_hash
        )

        logger.info( "[I!]-- Created documatic Invoice report '#{filename}'." )
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


  private


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
  # - <tt>:is_internal_copy</tt> => when greater than 0, the output is considered as an "internal copy" (not original).
  #
  # - <tt>:rjustification</tt> => numbers of blank fillers to be used for fixed-width floats;
  #   this is useful actually only for text file formatting, for PDF files ignore this option
  #   (justification is column based and layout-specific). Defaults to 0.
  #
  # - <tt>:do_float_formatting</tt> => set this != nil to convert to text and enforce a fixed text format for each float value
  #
  def prepare_report_data_hash( header_record, records, label_hash, options = {} )
    unless records.kind_of?( ActiveRecord::Relation )
      raise ArgumentError, "invoices_controller.prepare_report_data_hash(): invalid records parameter!", caller
    end
    unless header_record.kind_of?( ActiveRecord::Base )
      raise ArgumentError, "invoices_controller.prepare_report_data_hash(): invalid header_record parameter!", caller
    end
                                                    # == CURRENCY == Store currency name for later usage:
    currency_name  = header_record.get_currency_name
    currency_short = header_record.get_currency_symbol
                                                    # == DATA COLLECTION == Detail data table + summary:
    data_table = InvoiceRow.prepare_report_detail(  # Build the data set into Ruport's Table class
        :records => records,
        :rjustification => options[:rjustification].to_i
    )
                                                    # Compute summary sum via SQL mainly to get just the grand total, using the main constraint from the parent entity:
    computed_sums = InvoiceRow.prepare_summary_hash(
        :records => records,
        :do_float_formatting => options[:do_float_formatting]
    )
                                                    # Add the computed sums keys to the label hash:
    computed_sums.keys.each { |key|
      label_hash[ key ] = I18n.t( key, {:scope=>[:invoice_row]} )
    }
    grouping_total = computed_sums[:grand_total].to_s

    result_hash = {                                 # Prepare result hash:
      :is_internal_copy => params[:is_internal_copy],
      :report_title     => header_record.get_title_names().join(" - "),
      :report_base_name => header_record.get_base_name() + (params[:is_internal_copy] ? '_copy' : ''),
                                                    # Main data:
      :data_table       => data_table,
      :summary          => computed_sums,
      :label_hash       => label_hash,              # (This should be already translated and containing all the required label symbols)
      :currency_name    => currency_name,
      :currency_short   => currency_short,          # (currency display symbol or short name)
      :grouping_total   => grouping_total,
      :privacy_statement  => I18n.t( :privacy_statement )
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
                                  use_layout = :tab, skip_header = false )
    data = ''
                                                    # Check all supported layouts:
    if use_layout.to_sym == :tab
                                                    # --- REPORT HEADER: ---
      Invoice.report_header_symbols().each { |key|
        data << I18n.t( key, {:scope=>[:invoice_row]} )
        data << "#{separator} #{report_data_hash[key]}\r\n"
      }
      data << "\r\n"
                                                    # Localize column names:
      localize_ruport_table_column_names( report_data_hash[:data_table], :invoice_row, report_data_hash[:label_hash] )
                                                    # --- DATA ---
      if ( filetype =~ /csv/ )
        data << report_data_hash[:data_table].as( :csv, :format_options => {:col_sep => separator}, :ignore_table_width => true )
      else
        data << report_data_hash[:data_table].as( :text, :ignore_table_width => true, :alignment => :rjust )
      end
      data << "\r\n"
                                                    # --- ENDING SUMMARY: --- (Uses fixed width for floats)
      summary_table = InvoiceRow.prepare_summary_table( report_data_hash[:summary] )
      if ( filetype =~ /csv/ )
        data << summary_table.as( :csv, :format_options => {:col_sep => separator}, :ignore_table_width => true )
      else
        data << summary_table.as( :text, :ignore_table_width => true, :alignment => :rjust )
      end
      data << "\r\n"

    else                                            # == Any unsupported layout specified? ==
      # TODO ":flat" layout type (with no header) not needed yet
      data = "\r\n-- Unsupported layout format '#{use_layout}' specified! --\r\n\r\n"
    end

    data
  end
  # ---------------------------------------------------------------------------
end
