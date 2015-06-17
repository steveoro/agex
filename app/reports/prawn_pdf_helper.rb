# encoding: utf-8

=begin

== PrawnPDFHelper
Use this class as a parent to get access to the helper methods.

- version:  3.04.02.20130519
- author:   Steve A.

=end
class PrawnPDFHelper

  AUTHOR_STRING = 'AgeX5 - (p) FASAR Software, 2006-2013'


  # Draws the standard page header, with some report info on the top left and on the center, the page numbering on the top right and a separating horizontal line.
  #
  def self.standard_page_header( pdf, topleft_info_text, topcenter_info_text )
    pdf.move_cursor_to( pdf.margin_box.top() + 12 )
    pdf.text( self.italicize(topleft_info_text), :align => :left, :size => 6, :inline_format => true ) if topleft_info_text
    pdf.move_cursor_to( pdf.margin_box.top() + 12 )
    pdf.text(
      self.italicize( topcenter_info_text ),
      { :align => :center, :size => 8, :inline_format => true }
    ) if topcenter_info_text
    pdf.move_cursor_to( pdf.margin_box.top() + 5 )
    pdf.stroke_horizontal_rule()
  end
  # ----------------------------------------------------------------------------


  # Draws the standard page footer, with some report info on the center of the line.
  #
  def self.standard_page_footer( pdf, info_text )
    pdf.move_cursor_to( pdf.margin_box.bottom() - 6 )
    pdf.stroke_horizontal_rule()
    pdf.bounding_box( [50, -8],
                      :width => pdf.bounds.width - 100, :height => 6 ) do
      pdf.text( italicize( info_text ),
        { :align => :center, :size => 6, :inline_format => true }
      )
    end
    pdf.move_cursor_to( pdf.margin_box.bottom() - 14 )
    pdf.stroke_horizontal_rule()
  end
  # ----------------------------------------------------------------------------


  # Closes the PDF and sets the page numbering options.
  #
  def self.finalize_standard_report( pdf, page_numbering_at_y = -8 )
    pdf.stroke_color( "000000" )
    page_num_text = "Pag. <page>/<total>"
    numbering_options = {
      :at => [pdf.bounds.right - 150, page_numbering_at_y],
      :width => 150,
      :align => :right,
      :size => 6
    }
    pdf.number_pages( page_num_text, numbering_options )
  end
  # ---------------------------------------------------------------------------


  require 'ostruct'

  # Draws a multi-line text box with a rounded border for two text strings,
  # where each one can have its own format.
  #
  # The text supports inline formatting (see Prawn::Document::Text for info).
  #
  # === Sample usage of the option block with all recognized options:
  # The example shows some of the default values for the parameters.
  # Each member is optional.
  # <pre>
  #  rounded_dual_text_box( pdf, boldify(a_bold_name), some_detailed_info = nil ) { |o|
  #      o.x            = pdf.bounds.right - pdf.bounds.width
  #      o.y            = pdf.cursor()
  #      o.width        = 200                       # box width
  #      o.height       = 50                        # box height
  #      o.radius       = 5                         # radius of the rounded corner
  #      o.fill_color   = "e0f0e0"
  #      o.stroke_color = "000080"                  # (Navy)
  #      o.size         = 8                         # Heading and minimum font size
  #      o.align        = :left
  #      o.heading      = "My additional heading"   # (Always centered and in bold)
  #  }
  # </pre>
  #
  def self.rounded_dual_text_box( pdf, first_row, other_text = nil )
    opts = OpenStruct.new
    yield(opts)

    opts.x            ||= pdf.bounds.right - pdf.bounds.width / 2
    opts.y            ||= pdf.cursor() + 10
    opts.width        ||= 200
    opts.height       ||= 50
    opts.radius       ||= 5
    opts.fill_color   ||= "e0f0e0"
    opts.stroke_color ||= "000080"                # (Navy)
    opts.size         ||= 8
    opts.align        ||= :left
    opts.heading      ||= nil

    fill_color = pdf.fill_color()
    stroke_color = pdf.stroke_color()
    pdf.fill_color( opts.fill_color )
    pdf.stroke_color( opts.stroke_color )

    pdf.fill_and_stroke_rounded_polygon( opts.radius,
        [opts.x, opts.y], [opts.x+opts.width, opts.y],
        [opts.x+opts.width, opts.y-opts.height], [opts.x, opts.y-opts.height]
    )
    pdf.move_cursor_to( opts.y )

    pdf.bounding_box( [opts.x+4, opts.y],
                      :width => opts.width-8, :height => opts.height ) do
      if opts.heading
        pdf.move_cursor_to( pdf.bounds.top - 6 - opts.size )
        pdf.stroke_horizontal_rule()                # Draw a separator for the heading
        pdf.move_cursor_to( pdf.bounds.top )
      end
                                                    # Restore colors:
      pdf.fill_color( fill_color )
      pdf.stroke_color( stroke_color )

      if opts.heading
        pdf.move_down( 2 )
        pdf.pad( 4 ) do
          pdf.text(
            self.boldify( opts.heading ),
            { :size => opts.size, :align  => :center, :inline_format => true }
          )
        end
      else
        pdf.move_down( 4 )
      end

      font_size = other_text ? opts.size + 2 : opts.size
      pdf.move_down( 2 )

      pdf.indent( 4 ) do
        pdf.text( first_row,
          :align  => opts.align || :left,
          :size   => font_size,
          :inline_format => true
        )
        pdf.text( other_text,
          :align  => opts.align || :left,
          :size   => opts.size,
          :inline_format => true
        ) if other_text
      end
    end
  end
  #---------------------------------------------------------------------------
  #++

  # Adds a title text at the current y position, surrounded by a rounded rectangle
  # and supporting the same formatting options as #rounded_dual_text_box().
  #
  # The text supports inline formatting (see Prawn::Document::Text for info).
  #
  # === Sample usage of the option block with all recognized options:
  # The example shows some of the default values for the parameters.
  # Each member is optional.
  # <pre>
  #  rounded_dual_text_box( pdf, boldify(title_text) ) { |o|
  #    o.size          = 12
  #    o.width         ||= pdf.width_of( title_text )
  #    o.height        ||= 20
  #    o.x             ||= pdf.bounds.left + pdf.bounds.width / 2 - o.width / 2
  #    o.align         = :center
  #    o.fill_color    = "e0ffff"
  #    o.stroke_color  = "000080"
  #  }
  # </pre>
  #
  def self.add_title( pdf, title_text, align = :center )
    self.rounded_dual_text_box( pdf, title_text ) do |o|
      o.size          = 10
      o.width         ||= pdf.width_of( title_text )
      o.height        ||= 20
      o.x             ||= pdf.bounds.left + self.get_half_width(pdf) - o.width / 2
      o.align         = align
      o.fill_color    = "e0ffff"
      o.stroke_color  = "000080"
    end
  end
  # ---------------------------------------------------------------------------


  # Draws a subsection title in dark blue at current cursor Y.
  #
  # The text supports inline formatting (see Prawn::Document::Text for info).
  #
  def self.add_subsection_title( pdf, title_text, font_size = 12,
                                 indent = 100, align = :left )
    saved_color = pdf.fill_color()
    curr_y = pdf.y

    pdf.fill_color( "0000ff" )
    pdf.indent( indent ) do
      pdf.text( title_text,
        :align  => align,
        :size   => font_size,
        :inline_format => true
      )
    end
    pdf.fill_color( saved_color )
    pdf.move_cursor_to( curr_y )
  end
  # ---------------------------------------------------------------------------


  # Adds a left-justified header row composed of a label and a text, or a checkbox and a label in case of boolean values.
  # In case of Date or Time instances the values are formatted with Format#a_date().
  # Yields any option block passed (not compulsory).
  #
  # The text supports inline formatting (see Prawn::Document::Text for info).
  #
  # == Supported option fields:
  #   [+x+]
  #     the absolute x position; defaults to the left boundary
  #   [+y+]
  #     the absolute y position; defaults to current +cursor+() position
  #   [+label+_+font+_+size+]
  #     label text font size
  #   [+label+_+width+]
  #     label text maximum width; this works as a virtual column size for left & right padding calculation;
  #     default is 65, which is quite enough for a short label, like "Date", "From", "Subject" or something alike
  #   [+label+_+color+]
  #     label text fill color; default black
  #   [+value+_+font+_+size+]
  #     value text font size
  #   [+label+_+width+]
  #     value text maximum width; this works as a virtual column size for left & right padding calculation;
  #     default value is 0 = don't care (text will wrap on right boundary)
  #   [+value+_+color+]
  #     value text fill color; default black
  #
  # == Sample usage of the option block:
  # <pre>
  #     add_header_row( pdf, boldify(label), any_value ) { |o|
  #         o.label_font_size = 10
  #         o.label_width     = 80
  #         o.label_color     = "000000"
  #         o.value_font_size = 10
  #         o.value_color     = "000000"
  #     }
  # </pre>
  # When the block is not given the defaults apply.
  #
  def self.add_header_row( pdf, label, value, label_color = "000000",
                           value_color = "000000" )
    opts = OpenStruct.new
    yield(opts) if block_given?
                                                    # Set the default options:
    opts.x                ||= pdf.bounds.left
    opts.y                ||= pdf.cursor()
    opts.label_font_size  ||= 10
    opts.label_width      ||= 80
    opts.label_color      = label_color
    opts.value_font_size  ||= 10
    opts.value_width      ||= 0                     # 0 = don't care (text will wrap on pdf.bounds.right)
    opts.value_color      = value_color
                                                    # Move to position and save current color:
    pdf.move_cursor_to( opts.y )
    saved_color = pdf.fill_color()
    pdf.fill_color( opts.label_color )

                                                    # Draw the label: (use the Helvetica default font, so we can support additional formatting attributes,like bold or italic)
    pdf.indent( opts.x ) do
      pdf.text(
        "#{label}:",
        { :align => :left, :size => opts.label_font_size,
          :width => opts.label_width, :inline_format => true }
      )
    end
    pdf.move_cursor_to( opts.y )
    pdf.fill_color( opts.value_color )
                                                    # Draw the value: (Use a font with a complete charset - WARNING: DejaVuSans is a "vanilla-plain" font family, which excludes additional formatting attributes like bold or italic...)
    pdf.font( "Helvetica" ) do
#    pdf.font( "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf" ) do
      if ( value.instance_of?(TrueClass) || value.instance_of?(FalseClass) ||
           value == 'true' || value == 'false' )
        value = ( value.instance_of?(TrueClass) || value == 'true' )
        pdf.indent( opts.x + opts.label_width ) do
          pdf.fill_color( opts.value_color )
          pdf.text(
            "#{value ? '☒' : '❏'}",
            { :align => :left, :size => opts.value_font_size }
          )
        end
      else
        value = Format.a_date(value) if ( value.kind_of?(Time) || value.kind_of?(Date) )
        value = " " if ( value.nil? || value == '' )
        pdf.indent( opts.x + opts.label_width ) do
          pdf.fill_color( opts.value_color )
          pdf.text(
            value,
            { :align => :left, :size => opts.value_font_size,
              :width => ( opts.value_width > 0 ? opts.value_width : nil ) }
          )
        end
      end
    end

    pdf.fill_color( saved_color )
  end
  # ---------------------------------------------------------------------------


  # Adds (draws) an isolated cell at the specified coordinates.
  #
  def self.add_isolated_cell( pdf, curr_x, curr_y, width, height,
                              fill_color = "fff8dc", stroke_color = "000000" )
    saved_fill_color = pdf.fill_color()
    saved_stroke_color = pdf.stroke_color()

    pdf.fill_color( fill_color )
    pdf.stroke_color( stroke_color )
    pdf.fill_and_stroke_rectangle( [curr_x, curr_y], width, height )

    pdf.fill_color( saved_fill_color )
    pdf.stroke_color( saved_stroke_color )
  end
  # ---------------------------------------------------------------------------


  # Adds italic format to text.
  def self.italicize( text )
    text ? "<i>#{text}</i>" : ''
  end

  # Adds bold format to text.
  def self.boldify( text )
    text ? "<b>#{text}</b>" : ''
  end
  # ---------------------------------------------------------------------------


  # Draws a Ruport::Data::Table using an Hash of predefined (and localized) label
  # texts plus an optional Hash of individual column widths.
  #
  # An additional option block can be used to override the defaults, like this:
  # <pre>
  #     self.draw_table_with_columns_def( pdf, my_ruport_table, label_hash ) { |o|
  #         o.header_font_color   = "000000"
  #         o.header_font_size    = 10
  #         0.custom_column_align = { 0 => :center, 3 => :center }
  #     }
  # </pre>
  #
  # == Supported option fields (with defaults shown):
  #
  #      bounding_box_start   #=> nil,              # When set (for example to [pdf.bounds.left, pdf.cursor]), a Bounding box for the whole table will be used instead of a floating Span (Bounding Boxes are fixed in position on the page, even if they overflow)
  #      bounding_box_width   #=> pdf.bounds.width, # Bounding box or Span width (Maximum possible width of the table)
  #      bounding_box_height  #=> nil,
  #      table_width          #=> nil,
  #      default_row_align    #=> :right,
  #      default_header_align #=> :center,
  #      custom_column_align  #=> {}                # Use as members of the Hash: <column_index> => :left|:center|:right (enlist each column index that must change its internal alignment)
  #      title                #=> nil,              # Any string title for the table
  #      title_color          #=> "1030a0",
  #      title_font_size      #=> 10,
  #      font_size            #=> 8,
  #      header_font_size     #=> 8,
  #      header_color         #=> "eeffff",
  #      header_font_color    #=> "0000a0",
  #      row_color_even       #=> "fff8dc",
  #      row_color_odd        #=> "eeeeff",
  #      row_summary_length   #=> 0                 # This number of rows, starting from the bottom, will be considered as "summary" (a sort of footer for the table)
  #      row_color_summary    #=> nil               # When set (for example, to "ffffff"), the last "row_summary_length" rows of the table will have this background color
  #
  def self.draw_table_with_columns_def( pdf, ruport_table, label_hash, width_hash = {} )
    opts = OpenStruct.new
    yield(opts) if block_given?
                                                    # Set the default options:
    opts.bounding_box_width   ||= pdf.bounds.width
    opts.default_row_align    ||= :right
    opts.default_header_align ||= :center
    opts.custom_column_align  ||= {}
    opts.title_color          ||= "1030a0"
    opts.title_font_size      ||= 10
    opts.font_size            ||= 8
    opts.header_font_size     ||= 8
    opts.header_color         ||= "eeffff"
    opts.header_font_color    ||= "0000a0"
    opts.row_color_even       ||= "fff8dc"
    opts.row_color_odd        ||= "eeeeff"
    opts.row_summary_length   ||= 0
                                                    # Columns setup:
    fixed_column_widths = []
    ruport_table.rename_columns { |col_name|        # For each column, collect its prefixed width and change its name:
      fixed_column_widths << width_hash[ col_name.to_sym ]
      label_hash[col_name.to_sym] ? label_hash[col_name.to_sym] : col_name.to_s
    }

    table_array = [ ruport_table.column_names ]
    table_array += ruport_table.map { |row| row.to_a }
    table_array.map { |array|
      array.map! { |elem| elem.class != String ? elem.to_s : elem }
    }

    whole_table_format_opts = {
      :header         => true,
      :width          => opts.table_width,
      :column_widths  => fixed_column_widths
    }

                                                    # -- Actual formatting block:
    formatting_block_to_use =  Proc.new {
      if ( opts.title.kind_of?( String ) && opts.title.size > 0 )
        pdf.text(                                   # -- Table title:
          "<u><b>#{opts.title}</b></u>",
          { :align => :center, :size => opts.title_font_size, :inline_format => true }
        )
        pdf.move_down( 4 )
      end
                                                    # -- Main data table:
      pdf.table( table_array, whole_table_format_opts ) do
        cells.style( :size => opts.font_size, :inline_format => true, :align => opts.default_row_align )
        cells.style do |c|                          # For each cell...
          if ( opts.row_color_summary && opts.row_summary_length > 0 )
                                                    # Style the summary rows:
            if ( c.row >= table_array.size - opts.row_summary_length)
              c.background_color = opts.row_color_summary
              c.borders = (c.row == table_array.size-1) ? [:left, :right, :bottom] : [:left, :right]
            else
              c.background_color = (c.row % 2).zero? ? opts.row_color_even : opts.row_color_odd
            end
          else                                      # Style the normal/standard rows:
            c.background_color = (c.row % 2).zero? ? opts.row_color_even : opts.row_color_odd
          end
        end
        if ( opts.custom_column_align.kind_of?( Hash ) && opts.custom_column_align.size > 0 )
          opts.custom_column_align.each { |value, key| columns(key).style( :align => value ) }
        end
        rows(0).style(                              # Style the header last, overwriting all other defaults and specials:
          :background_color => opts.header_color,
          :text_color       => opts.header_font_color,
          :align            => opts.default_header_align,
          :size             => opts.header_font_size
        )
      end
    }
                                                    # Apply the formatting block:
    if opts.bounding_box_start
      pdf.bounding_box(
        opts.bounding_box_start, :width => opts.bounding_box_width, :height => opts.bounding_box_height
      ) do
         formatting_block_to_use.call()
      end
    else
      # [20130519, Steve]: table auto-size/auto-center does it better than span; removing it:
#      pdf.span( opts.bounding_box_width, :position => :center ) do
        formatting_block_to_use.call()
#      end
    end
  end
  # -------------------------------------------------------------------------


  protected


  # Returns the half width of the page.
  def self.get_half_width( pdf )
    pdf.bounds.width / 2
  end


  # Returns the full string for a field composed from a label and its value.
  #
  def self.get_composed_field( label, value )
    ( value ? "#{label}: #{value}" : nil )
  end
  # ---------------------------------------------------------------------------
end
# -----------------------------------------------------------------------------
