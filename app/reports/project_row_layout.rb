# encoding: utf-8

=begin

== ProjectRowLayout

- version:  3.03.11.20130416
- author:   Steve A.

=end
require "ruport"
require "prawn"

require 'common/format'
require 'prawn_pdf_helper'


class ProjectRowLayout < PrawnPDFHelper

  # Prepares rendering options, default values and starts the rendering
  # process.
  #
  # == Options:
  #
  # - <tt>:report_title<\tt> (required) =>
  #   a String description for the report title.
  #
  # - <tt>:label_hash<\tt> (required) =>
  #   Hash of all the possible (and already localized) string labels to be used as column heading titles or text labels in general.
  #   The keys of the hash should be symbols.
  #
  # - <tt>:parent_record<\tt> (required) =>
  #   the master model instance (or header row) linked to the parent ids of the detail rows being processed.
  #
  # - <tt>:data_grouping<\tt> (required) =>
  #   a Ruport::Data::Grouping containing several data Groups to be processed.
  #
  # - <tt>:grouping_total<\tt> =>
  #   a verbose (String) representation of the total cost for all the collection detail rows computed using the parent row id.
  #
  # - <tt>:cost_summary<\tt> (required) =>
  #   a Ruport::Data::Table obtained from the cost summary among each single data group, selecting unique values of the group ids as main key.
  #   See Ruport::Data::Grouping#summary().
  #
  # - <tt>:subtot_tables_hash<\tt> (required) =>
  #   an Hash composed of Group name with Ruport::Data::Table pairs, one for each name of the <tt>data_grouping<\tt>.
  #   Each table contains just the additional computation rows (5 in total) to be added to the data table before the rendering.
  #
  # - <tt>:grandtot_table<\tt> (required) =>
  #   a Ruport::Data::Table summarizing each subtotal for each data group.
  #
  # - <tt>:grandtot_sums<\tt> (required) =>
  #   the subtable portion of the table above, containing just the grandtotal computation.
  #   To be rendered together with grandtot_table.
  #
  # - <tt>:entry_types_table</tt> (required) => 
  #   a Ruport::Data::Table summarizing each possible code value of the field entry_type.
  #
  # - <tt>:date_from</tt> / <tt>:date_to</tt> => 
  #   String dates representing the starting and ending filter range for this collection of rows.
  #   Both are not required (none, one or both can be supplied as options).
  #
  def self.render( options = { :header_data => [{}], :detail_data => [] } )
                                                    # Check the (complex) option parameters:
    raise "Invalid 'report_title' option parameter! Non-empty String expected." unless ( options[:report_title].instance_of?(String) && options[:report_title].size > 0 )
    raise "Invalid 'label_hash' option parameter! Non-empty Hash expected." unless ( options[:label_hash].instance_of?(Hash) && options[:label_hash].size >= 1 )
    raise "Invalid 'subtot_tables_hash' option parameter! Non-empty Hash expected." unless ( options[:subtot_tables_hash].instance_of?(Hash) && options[:subtot_tables_hash].size >= 1 )

    raise "Invalid 'cost_summary' option parameter! Ruport::Data::Table expected." unless ( options[:cost_summary].instance_of?(Ruport::Data::Table) )
    raise "Invalid 'grandtot_table' option parameter! Ruport::Data::Table expected." unless ( options[:grandtot_table].instance_of?(Ruport::Data::Table) )
    raise "Invalid 'grandtot_sums' option parameter! Ruport::Data::Table expected." unless ( options[:grandtot_sums].instance_of?(Ruport::Data::Table) )
    raise "Invalid 'entry_types_table' option parameter! Ruport::Data::Table expected." unless ( options[:entry_types_table].instance_of?(Ruport::Data::Table) )
# TODO check correct data types for these two:
    raise "Invalid 'data_grouping' option parameter!" unless ( options[:data_grouping].instance_of?(Ruport::Data::Grouping) )
    raise "Invalid 'parent_record' option parameter!" if ( options[:parent_record].nil? )

    options[:pdf_format] = {
      :page_size      => 'A4',
      :page_layout    => :portrait,
                                                  # Document margins (in PS pts):
      :left_margin    => 30,
      :right_margin   => 30,
      :top_margin     => 30,
      :bottom_margin  => 30,
                                                  # Metadata:
      :info => {
        :Title        => options[:report_title],
        :Author       => AUTHOR_STRING,
        :Subject      => options[:label_hash][ :meta_info_subject ],
        :Keywords     => options[:label_hash][ :meta_info_keywords ],
        :Creator      => "AgeX5",
        :Producer     => "Prawn @ AgeX5 framework",
        :CreationDate => Time.now
      }
    }

    pdf = Prawn::Document.new( options[:pdf_format] )

    self.build_page_header( pdf, options )
    self.build_page_footer( pdf, options )

    self.build_data_header( pdf, options )
    self.build_report_body( pdf, options )

    self.finalize_standard_report( pdf )
    pdf.render()
  end
  # --------------------------------------------------------------------------


  protected


  # Builds and adds a page header on each page.
  #
  def self.build_page_header( pdf, options )
    data_filtered_from_label = (
      (options[:date_from].nil? || options[:date_from].empty?) && (options[:date_to].nil? || options[:date_to].empty?) ? '' : "#{options[:label_hash][:filtering_label]}:"
    ) + (
      (options[:date_from].nil? || options[:date_from].empty?) ? '' : " #{options[:date_from]}"
    ) + (
      (options[:date_to].nil? || options[:date_to].empty?) ? '' : " ... #{options[:date_to]}"
    )
    pdf.repeat( :all ) do
      self.standard_page_header( pdf, AUTHOR_STRING, data_filtered_from_label )
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


  def self.finalize_standard_report( pdf )
    pdf.stroke_color( "000000" )
    page_num_text = "Pag. <page>/<total>"
    numbering_options = {
      :at => [pdf.bounds.right - 150, 2],
      :width => 150,
      :align => :right,
      :size => 6
    }
    pdf.number_pages( page_num_text, numbering_options )
  end
  # ---------------------------------------------------------------------------


  # Builds a one-timer report (data) header for the first page, formatting each piece of information of
  # the Project header record in a form-like manner.
  #
  def self.build_data_header( pdf, options )
    half_width = self.get_half_width(pdf)
    pdf.move_cursor_to( pdf.bounds.top() )
    pdf.move_down( 30 )
    self.add_title( pdf, "#{options[:label_hash][ :project ]}: #{ self.boldify(options[:report_title]) }" )
    pdf.move_down( 8 )
    self.add_custom_header_row( pdf, options[:label_hash][ :codename ], options[:parent_record].codename )
    self.add_custom_header_row( pdf, options[:label_hash][ :description ], options[:parent_record].description )
    self.add_custom_header_row( pdf, options[:label_hash][ :parent_project ], options[:parent_record].get_parent_project_name )
    pdf.move_down( 8 )
    self.add_custom_header_row( pdf, options[:label_hash][ :firm ], options[:parent_record].get_firm_name )
    self.add_custom_header_row( pdf, options[:label_hash][ :partner ], options[:parent_record].get_partner_name )
    self.add_custom_header_row( pdf, options[:label_hash][ :committer ], options[:parent_record].get_committer_name )
    self.add_custom_header_row( pdf, options[:label_hash][ :team_group ], options[:parent_record].get_team_name )
    pdf.move_down( 8 )
    self.add_custom_header_row( pdf, options[:label_hash][ :date_start ], Format.a_date( options[:parent_record].date_start ) )
    restart_y = pdf.cursor()
    self.add_custom_header_row( pdf, options[:label_hash][ :date_end ], Format.a_date( options[:parent_record].date_end ) )
    self.add_custom_header_row( pdf, options[:label_hash][ :esteemed_price ], options[:parent_record].esteemed_price.to_s )

    self.add_custom_header_row( pdf, options[:label_hash][ :has_gone_gold ], options[:parent_record].has_gone_gold, restart_y + 4, half_width )
    self.add_custom_header_row( pdf, options[:label_hash][ :is_closed ], options[:parent_record].is_closed, pdf.cursor(), half_width )

    self.add_custom_header_row( pdf, options[:label_hash][ :has_been_invoiced ], options[:parent_record].has_been_invoiced, restart_y + 4, half_width * 1.5 )
    self.add_custom_header_row( pdf, options[:label_hash][ :is_a_demo ], options[:parent_record].is_a_demo, pdf.cursor(), half_width * 1.5 )
    pdf.move_down( 8 )
    self.add_custom_header_row( pdf, options[:label_hash][ :notes ], options[:parent_record].notes )
  end
  # -------------------------------------------------------------------------


  # Builds the report body.
  #
  # This is composed of at least 4 tables: 2 summaries at the start, a table for each
  # data group passed as option, plus a final "grand total" table at the end.
  #
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

    half_width = self.get_half_width(pdf)
    start_y = pdf.cursor() - 8
    pdf.move_down( 8 )

    self.draw_table_with_columns_def( pdf, options[:cost_summary], options[:label_hash] ) { |o|
      o.bounding_box_start  = [pdf.bounds.left, pdf.cursor]
      o.bounding_box_width  = half_width
      o.table_width         = half_width
      o.title               = options[:label_hash][:resource_summary_title]
      o.title_color         = "1030a0"
      o.title_font_size     = 7
      o.font_size           = 7
      o.header_font_size    = 7
      o.header_color        = "ffffff"
      o.header_font_color   = "303030"
      o.row_color_even      = "f7f7f7"
      o.row_color_odd       = "e0e0e0"
    }
    pdf.move_down( 8 )
    end_y = pdf.cursor()

    pdf.move_cursor_to( start_y )
    self.draw_table_with_columns_def( pdf, options[:entry_types_table], options[:label_hash] ) { |o|
      o.bounding_box_start  = [pdf.bounds.left + half_width + half_width * 0.3, pdf.cursor]
      o.bounding_box_width  = half_width * 0.5
      o.table_width         = half_width * 0.5
      o.title               = options[:label_hash][:activity_summary_title]
      o.title_color         = "1030a0"
      o.title_font_size     = 7
      o.font_size           = 7
      o.header_font_size    = 7
      o.header_color        = "ffffff"
      o.header_font_color   = "303030"
      o.row_color_even      = "f7f7f7"
      o.row_color_odd       = "e0e0e0"
    }
    pdf.move_down( 12 )

    options[:data_grouping].each { |n,g|
      self.draw_table_with_columns_def( pdf, g + options[:subtot_tables_hash][n], options[:label_hash] ) { |o|
        o.bounding_box_width  = pdf.bounds.width
        o.table_width         = pdf.bounds.width
        o.title               = (n.nil? || n == '') ? '(?)': n   # (avoid missing titles)
        o.title_color         = "1030a0"
        o.title_font_size     = 10
        o.font_size           = 8
        o.header_font_size    = 8
        o.header_color        = "eeffff"
        o.header_font_color   = "000080"
        o.row_color_even      = "fff8dc"
        o.row_color_odd       = "fff8dc"
        o.row_summary_length  = 4
        o.row_color_summary   = "ffffff"
      }
      if ( pdf.cursor() < 120 )                     # If there's not enough space for the grand-total table, let's use another page:
        pdf.start_new_page()
        pdf.move_cursor_to( pdf.bounds.top - 40 )
      else
        pdf.move_down( 12 )
      end
    }

    if ( pdf.cursor() < 100 )                       # If there's not enough space for the grand-total table, let's use another page:
      pdf.start_new_page()
      pdf.move_cursor_to( pdf.bounds.top - 40 )
    end

    self.draw_table_with_columns_def( pdf, options[:grandtot_table] + options[:grandtot_sums], options[:label_hash] ) { |o|
      o.bounding_box_width  = half_width * 1.6
      o.title               = options[:label_hash][:global_summary_title]
      o.title_color         = "1030a0"
      o.title_font_size     = 10
      o.font_size           = 8
      o.header_font_size    = 8
      o.header_color        = "ffffff"
      o.header_font_color   = "000080"
      o.row_color_even      = "eeffee"
      o.row_color_odd       = "eeeeff"
      o.row_summary_length  = 1
      o.row_color_summary   = "ffffff"
    }

    pdf.move_down( 12 )
    pdf.stroke_color( "000000" )
    pdf.bounding_box( [pdf.bounds.left, pdf.cursor()], :width => half_width * 1.6 ) do
      pdf.text(
        self.boldify( "#{options[:label_hash][ :grouping_total_label ]}: #{options[:grouping_total]}" ),
        { :align => :right, :size => 9, :inline_format => true } 
      )
    end
  end 
  # -------------------------------------------------------------------------


  private


  # Writes a custom header line.
  # Wrapper for PrawnPDFHelper#add_header_row() to get a customized multi column layout with all black labels.
  #
  def self.add_custom_header_row( pdf, label, value, y_pos = pdf.cursor(), x_pos = pdf.bounds.left() )
    self.add_header_row( pdf, label, value.to_s, "0000a0" ) { |o|
      o.x               = x_pos
      o.y               = y_pos
      o.label_font_size = 8
      o.value_font_size = 8
    }
  end
  # -------------------------------------------------------------------------
end
