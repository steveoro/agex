# encoding: utf-8

=begin

== InvoiceRowLayout

- version:  3.04.02.20130519
- author:   Steve A.

=end
require "ruport"
require "prawn"

require 'common/format'
require 'prawn_pdf_helper'


class AccountRowLayout < PrawnPDFHelper

  # Prepares rendering options, default values and starts the rendering
  # process.
  #
  # == Options:
  # - <tt>:report_title<\tt> (required) =>
  #   a String description for the report title.
  #
  # - <tt>:label_hash<\tt> (required) =>
  #   Hash of all the possible (and already localized) string labels to be used as column heading titles or text labels in general.
  #   The keys of the hash should be symbols.
  #
  # - <tt>:data_table<\tt> (required) =>
  #   a collection of detail rows to be processed.
  #
  # - <tt>:summary_rows<\tt> (required) =>
  #   an Array of 2 row-arrays, containing the summarized totals of data_table, formatted using the same column alignment
  #
  # - <tt>:grouping_total<\tt>
  #     a verbose (String) representation of the total cost for all the collection detail rows computed using the parent row id.
  #
  # - <tt>:date_from<\tt>, <tt>:date_to<\tt>
  #     a String date representing the filtering range for this collection of rows.
  #
  def self.render( options = { :label_hash => {} } )
    options[:date_from] ||= ""
    options[:date_to] ||= ""
    options[:grouping_total] ||= ""

    options[:pdf_format] = {
      :page_size      => 'A4',
      :page_layout    => :landscape,
                                                    # Document margins (in PS pts):
      :left_margin    => 30,
      :right_margin   => 30,
      :top_margin     => 40,
      :bottom_margin  => 40,
                                                    # Metadata:
      :info => {
        :Title        => options[:report_title],
        :Author       => AUTHOR_STRING,
        :Subject      => options[:label_hash][ :meta_info_subject ],
        :Keywords     => options[:label_hash][ :meta_info_keywords ],
        :Creator      => "AmbGest3",
        :Producer     => "Prawn @ AgeX5 framework",
        :CreationDate => Time.now
      }
    }

    pdf = Prawn::Document.new( options[:pdf_format] )

    self.build_page_header( pdf, options )
    self.build_page_footer( pdf, options )
    self.build_report_body( pdf, options )
    self.finalize_standard_report( pdf )
    pdf.render()
  end 
  # ---------------------------------------------------------------------------


  protected


  # Builds and adds a page header on each page.
  #
  def self.build_page_header( pdf, options )
    pdf.repeat( :all ) do
      self.standard_page_header( pdf, AUTHOR_STRING, "#{options[:label_hash][:filtering_label]}: #{options[:date_from]} ... #{options[:date_to]}" )
    end
  end
  # --------------------------------------------------------------------------


  # Builds and adds a page footer on each page.
  #
  def self.build_page_footer( pdf, options )
    pdf.repeat( :all ) do
      self.standard_page_footer( pdf, "#{options[:label_hash][:report_created_on]}: #{Format.a_short_datetime( DateTime.now )}" )
    end
  end
  # ---------------------------------------------------------------------------


  # Builds the report body, redefining also the margins to avoid overwriting on
  # page headers and footers.
  #
  def self.build_report_body( pdf, options )
# DEBUG
#    puts "\r\n-----------------------------------------"
#    puts "#{options[:data_table].inspect}"
#    puts "******** label_hash *********************"
#    puts "#{options[:label_hash].inspect}"
#    puts "---------- column names: ----------------"
#    puts "#{options[:data_table].column_names.inspect}\r\n"
#    puts "#{options[:summary_rows].inspect}\r\n"
                                                    # Table data & column names adjustments:
    table = options[:data_table]
    table.rename_columns { |col_name|
      options[:label_hash][col_name.to_sym] ? options[:label_hash][col_name.to_sym] : col_name.to_s
    } 

    table_array = [ table.column_names ]
    table_array += table.map { |row| row.to_a }
    table_array.map { |array|
      array.map! { |elem| elem.class != String ? elem.to_s : elem }
    }

                                                    # Adjust dynamic column widths:
    cw = pdf.bounds.width / 10
    cwsm = cw * 2 / 3
    fixed_column_widths = [
        cwsm,   # date
        cwsm,   # subject firm
        cw*4,   # description
        cwsm,   # value
        cwsm,   # macro-type
        cwsm,   # type
        cwsm,   # payment type
        cwsm    # check num.
    ]
                                                    # Compute remaining width for the last column:
    tot_width_so_far = fixed_column_widths.inject(0) {|s,e| s+e }
                                                    # Append dynamic width for Notes column:
    fixed_column_widths << (pdf.bounds.width - tot_width_so_far)
# DEBUG
#    puts "\r\n-- bounds.width #{pdf.bounds.width.inspect}"
#    puts "-- cw #{cw.inspect}"
#    puts "-- cwsm #{cwsm.inspect}"
#    puts "-- fixed_column_widths: #{fixed_column_widths.inspect}\r\n"
    whole_table_format_opts = {
      :header         => true,
      :column_widths  => fixed_column_widths
    }

    pdf.bounding_box( [0, pdf.bounds.height - 10],
                      :width => pdf.bounds.width,
                      :height => pdf.bounds.height - 20 ) do
                                                    # -- Report title:
      pdf.text(
        "<u><b>#{options[:report_title]}</b></u>",
        { :align => :center, :size => 10, :inline_format => true } 
      )
                                                    # -- Main data table:
      pdf.move_down( 10 )
      pdf.table( table_array, whole_table_format_opts ) do
        cells.style( :size => 8, :inline_format => true, :align => :right )
        cells.style do |c|
          c.background_color = (c.row % 2).zero? ? "ffffff" : "eeeeee"
        end
        rows(0).style(
          :background_color => "c0ffc0",
          :text_color       => "00076d",
          :align            => :center,
          :size             => 7,
          :overflow         => :shrink_to_fit,
          :min_font_size    => 6
        )
      end
                                                    # -- Grouping total:
      pdf.move_down( 10 )
      pdf.text(
        self.boldify( "#{options[:label_hash][ :grouping_total_label ]}: #{options[:grouping_total]} #{options[:currency_name]}" ),
        { :align => :center, :size => 8, :inline_format => true } 
      )

                                                    # -- Summary sub-table:
      pdf.move_down( 10 )
      pdf.table(
        options[:summary_rows],
        { :header => true } 
      ) do
        cells.style(
          :size => 8,
          :inline_format => true,
          :align => :right,
          :background_color => "ffffcc"
        )
        rows(0).style(
          :background_color => "c0ffc0",
          :text_color       => "00076d",
          :align            => :center,
          :size             => 7,
          :overflow         => :shrink_to_fit,
          :min_font_size    => 6
        )
      end
    end
  end 
  # ---------------------------------------------------------------------------
end