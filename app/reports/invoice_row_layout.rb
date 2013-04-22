# encoding: utf-8

=begin

== InvoiceRowLayout

- version:  3.03.11.20130415
- author:   Steve A.

=end
require "ruport"
require "prawn"

require 'common/format'
require 'prawn_pdf_helper'


class InvoiceRowLayout < PrawnPDFHelper

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
  # - <tt>:header_data<\tt> (required) =>
  #   an Hash of header fields for the layout.
  #
  # - <tt>:data_table<\tt> (required) =>
  #   an instance of a Ruport::Data::Table (compiled from detail data rows) that has to be processed.
  #
  # - <tt>:is_internal_copy</tt> => when greater than 0, the output is considered as an "internal copy" (not original).
  #
  # - <tt>:summary<\tt> =>
  #   an +Hash+ containing the results of a InvoiceRow.prepare_summary_hash call.
  #
  def self.render( options = {} )
                                                    # Check the (complex) option parameters:
    raise "Invalid 'data_table' option parameter! Ruport::Data::Table expected." unless ( options[:data_table].instance_of?(Ruport::Data::Table) )
    raise "Invalid 'label_hash' option parameter! Non-empty Hash expected." unless ( options[:label_hash].instance_of?(Hash) && options[:label_hash].size >= 1 )
    raise "Invalid 'summary' option parameter! Non-empty Hash expected." unless ( options[:summary].instance_of?(Hash) && options[:summary].size >= 1 )
    raise "Invalid 'date' option parameter!" if ( options[:date].nil? )
    raise "Invalid 'report_title' option parameter! Non-empty String expected." unless ( options[:report_title].instance_of?(String) && options[:report_title].size > 0 )
    raise "Invalid 'customer_name' option parameter! Non-empty String expected." unless ( options[:customer_name].instance_of?(String) && options[:customer_name].size > 0 )
    raise "Invalid 'header_object' option parameter! Non-empty String expected." unless ( options[:header_object].instance_of?(String) && options[:header_object].size > 0 )

    options[:pdf_format] = {
      :page_size      => 'A4',
      :page_layout    => :portrait,
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
        :Creator      => "AgeX5",
        :Producer     => "Prawn @ AgeX5 framework",
        :CreationDate => Time.now
      }
    }

    pdf = Prawn::Document.new( options[:pdf_format] )

    self.build_invoice_header( pdf, options )
    self.build_invoice_body( pdf, options )
    self.build_invoice_footer( pdf, options )

    self.finalize_standard_report( pdf )
    pdf.render()
  end 
  # ---------------------------------------------------------------------------


  protected


  # Column width hash, containing the exact column width in PDF measure units for each column (symbol) rendered by these helper methods.
  #
  WIDTH_HASH = {
    :round_quantity       => 28,
    :le_invoice_row_unit  => 30,
    :description          => 200,
    :unit_cost            => 45,
    :taxable_amount       => 50,
    :discount_percent     => 32,
    :vat_tax_percent      => 40,
    :net_tax              => 50,
    :net_amount           => 60
  }


  # Builds the report body, redifining also the margins to avoid overwriting on
  # page headers and footers.
  #
  def self.build_invoice_body( pdf, options )
# DEBUG
#    puts "\r\n******************** label_hash *************************"
#    puts "#{options[:label_hash].inspect}"
#    puts "------------- data_table, column names: -------------"
#    puts "#{options[:data_table].column_names.inspect}"
#    puts "---------------------------------------------------------"
#    puts "#{options[:summary].inspect}\r\n"

                                                    # Add Invoice Date + Subject:
    pdf.move_down(20)                               # move down to leave a little space before table start
    self.add_header_row( pdf, boldify(options[:label_hash][ :date ]), options[:date] ) { |o|
      o.label_width = 70
    }
    pdf.move_down(10)                               # move down to leave a little space before table start
    self.add_header_row( pdf, boldify(options[:label_hash][ :header_object ]), options[:header_object] ) { |o|
      o.label_width = 70
    }
    pdf.move_down(20)                               # move down to leave a little space before table start

                                                    # Table data & column names adjustments:
    table = options[:data_table]
    fixed_column_widths = []
    table.rename_columns { |col_name|               # For each column, collect its prefixed width and change its name:
      fixed_column_widths << WIDTH_HASH[ col_name.to_sym ]
      options[:label_hash][col_name.to_sym] ? options[:label_hash][col_name.to_sym] : col_name.to_s
    } 

    table_array = [ table.column_names ]
    table_array += table.map { |row| row.to_a }
    table_array.map { |array|
      array.map! { |elem| elem.class != String ? elem.to_s : elem }
    }

# DEBUG
#    puts "\r\n-- bounds.width #{pdf.bounds.width.inspect}"
#    puts "-- fixed_column_widths: #{fixed_column_widths.inspect}\r\n"

    whole_table_format_opts = {
      :header         => true,
      :column_widths  => fixed_column_widths
    }
                                                    # -- Main data table:
    pdf.bounding_box( [pdf.bounds.left, pdf.cursor()],
                      :width => pdf.bounds.width ) do
      pdf.table( table_array, whole_table_format_opts ) do
        cells.style( :size => 8, :inline_format => true, :align => :right )
        cells.style do |c|
          c.background_color = (c.row % 2).zero? ? "fff9ed" : "fff8dc"
        end
        columns(1).style( :align => :left )         # invoice_row_unit
        columns(2).style( :align => :left )         # description
        rows(0).style(
          :background_color => "eeffff",
          :text_color       => "00076d",
          :align            => :center,
          :size             => 6
        )
      end

      self.build_invoice_summary( pdf, options )
    end

    pdf.move_down( 10 )
    self.build_notes( pdf, options )
  end 
  # ---------------------------------------------------------------------------


  # Builds and adds a page header on each page.
  #
  def self.build_invoice_header( pdf, options )
    pdf.move_cursor_to( pdf.bounds.top )
    width = options[:header_width] || (pdf.bounds.width / 2) - 20

    pdf.bounding_box( [pdf.bounds.left, pdf.bounds.top], :width => width ) do
      if options[:company_logo_big]
          pdf.image( options[:company_logo_big], :width => (width - 30), :position => :left )
      else
        pdf.indent( 10 ) do
          pdf.text(
            boldify( options[:company_name] ),
            { :align => :left, :size => 16, :inline_format => true }
          )
        end
      end

      company_info = get_firm_info( options, options[:company_full_address], 
                                    :company_phone_main, :company_phone_hq, :company_phone_fax, 
                                    :company_e_mail, :company_tax_code, :company_vat_registration )
      pdf.move_down( 10 )
      pdf.text( company_info, { :align => :left, :size => 8, :inline_format => true } )

      if options[:is_internal_copy]
        pdf.move_down( 30 )
        pdf.text(
          italicize( options[:label_hash][:copy_watermark] ),
          { :align => :center, :size => 8, :inline_format => true }
        )
      end
    end

    pdf.move_cursor_to( pdf.bounds.top )
    width = options[:header_width] || (pdf.bounds.width / 2)

    pdf.bounding_box( [pdf.bounds.left + width, pdf.bounds.top - 20], :width => width ) do
      self.add_title(
        pdf,
        self.get_composed_field( options[:label_hash][ :report_title ], boldify(options[:report_title]) ),
        :center
      )
      pdf.move_down( 20 )
      customer_info = get_firm_info( options, options[:customer_full_address], 
                                     :customer_phone_main, :customer_phone_hq, :customer_phone_fax, 
                                     :customer_e_mail, :customer_tax_code, :customer_vat_registration )
      self.rounded_dual_text_box( pdf, boldify(options[:customer_name]), customer_info ) { |o| 
          o.width     = 270
          o.height    = options[:header_height] || 120
          o.heading   = boldify( options[:label_hash][ :customer ] )
          o.size      = options[:header_font_size] || 10
          o.align     = :left
          o.x         = pdf.bounds.right - 270
      }
    end
  end
  # --------------------------------------------------------------------------


  # Builds and adds a page footer on each page.
  #
  def self.build_invoice_footer( pdf, options )
    pdf.move_cursor_to( pdf.bounds.bottom + 68 )

    pdf.stroke_horizontal_rule()
    pdf.pad( 5 ) do
      pdf.indent( 10 ) do
        if options[:company_logo_short]
            pdf.image( options[:company_logo_short], :width => 180, :position => :left )
        else
          pdf.text(
            boldify( options[:company_name] ),
            { :align => :left, :size => 12, :inline_format => true }
          )
        end
        pdf.move_down( 7 )
        pdf.text(
          self.build_banking_coordinates( options ),
          { :align => :left, :size => 8, :inline_format => true }
        )
      end
    end

    pdf.stroke_horizontal_rule()
    pdf.pad( 5 ) do
      if options[:privacy_statement]
        pdf.indent( 10 ) do
          pdf.text(
            italicize(options[:privacy_statement]),
            { :align => :left, :size => 6, :inline_format => true }
          )
        end
      end
    end

    pdf.stroke_horizontal_rule()
  end
  # ---------------------------------------------------------------------------


  def self.finalize_standard_report( pdf )
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


  private


  def self.build_invoice_summary( pdf, options )
    self.build_summary_row( pdf,
      options[:label_hash][ :subtotal ],
      nil,
      options[:summary][ :subtotal ], true # is_highlighted = true
    )
    self.build_summary_row( pdf,
      options[:label_hash][ :social_security_cost ],
      options[:summary][ :social_security_cost ],
      options[:summary][ :social_security_amount ], true
    )
    self.build_summary_row( pdf,
      options[:label_hash][ :total_taxable_amount ],
      nil,
      options[:summary][ :total_taxable_amount ]
    )
    self.build_summary_row( pdf,
      options[:label_hash][ :total_tax ],
      options[:vat_tax],
      options[:summary][ :total_tax ], true
    )
    self.build_summary_row( pdf,
      options[:label_hash][ :total ],
      nil,
      boldify(options[:summary][ :total ])
    )
    self.build_summary_row( pdf,
      options[:label_hash][ :account_wage ],
      options[:summary][ :account_wage ],
      options[:summary][ :account_wage_amount ], true
    )
    self.build_summary_row( pdf,
      options[:label_hash][ :total_expenses ],
      nil,
      options[:summary][ :total_expenses ]
    )
    self.build_summary_row( pdf,
      boldify(options[:label_hash][ :grand_total ]),
      nil,
      boldify(options[:summary][ :grand_total ]), true
    )
  end


  # Draws additional Notes on the invoice.
  #
  def self.build_notes( pdf, options )
    pdf.indent( 10 ) do
      pdf.text(
        boldify( "#{options[:label_hash][:notes_title]}:" ),
        { :align => :left, :size => 10, :inline_format => true }
      )
      if ( options[:notes_text].kind_of?(Array) )
        multi_line_text = options[:notes_text] * "\r\n\r\n"
      else
        multi_line_text = options[:notes_text]
      end
      pdf.text(
        multi_line_text,
        { :align => :left, :size => 10, :inline_format => true }
      ) if options[:notes_text]
    end
  end
  # ---------------------------------------------------------------------------


  # Draws a right-justified summary row at the current Y position, composed of a label
  # (either highlighted in bold or not) followed by a cell for a numeric percentage and
  # another cell for a specific numeric amount.
  #
  def self.build_summary_row( pdf, label, percentage, amount, is_highlighted = false )
    label_column_start = WIDTH_HASH[ :round_quantity ] + WIDTH_HASH[ :le_invoice_row_unit ] +
                         WIDTH_HASH[ :description ]
    label_column_width = WIDTH_HASH[ :unit_cost ] + WIDTH_HASH[ :taxable_amount ] +
                         WIDTH_HASH[ :discount_percent ] + WIDTH_HASH[ :vat_tax_percent ]
    pdf.bounding_box( [pdf.bounds.left + label_column_start, pdf.cursor() - 5],
                      :width => label_column_width - 4 ) do
      pdf.text(
        "#{label}:",
        { :align => :right, :size => 8, :inline_format => true }
      )
    end
    pdf.move_up( 14 )

    if percentage
      self.add_isolated_cell(
          pdf,
          pdf.bounds.left + label_column_start + label_column_width,
          pdf.cursor(),
          WIDTH_HASH[ :net_tax ],
          15
      ) if is_highlighted

      pdf.bounding_box(
          [pdf.bounds.left + label_column_start + label_column_width, pdf.cursor() - 5],
          :width => WIDTH_HASH[ :net_tax ] - 4
      ) do
        pdf.text(
          percentage.to_s,
          { :align => :right, :size => 8, :inline_format => true }
        )
      end        
      pdf.move_up( 14 )
    end

    self.add_isolated_cell(
        pdf,
        pdf.bounds.left + label_column_start + label_column_width + WIDTH_HASH[ :net_tax ],
        pdf.cursor(),
        WIDTH_HASH[ :net_amount ],
        15
    ) if is_highlighted

    pdf.bounding_box(
        [pdf.bounds.left + label_column_start + label_column_width + WIDTH_HASH[ :net_tax ], pdf.cursor() - 5],
        :width => WIDTH_HASH[ :net_amount ] - 4
    ) do
      pdf.text(
        amount.to_s,
        { :align => :right, :size => 8, :inline_format => true }
      )
    end
  end


  # Returns a single string field composed of all the information regarding a firm, retrieved by its column symbols.
  #
  def self.get_firm_info( options, full_address, phone_main_sym, phone_hq_sym, phone_fax_sym, 
                          e_mail_sym, tax_code_sym, vat_registration_sym )
    label_hash = options[:label_hash]
    return [
      full_address,
      [
        self.get_composed_field( self.get_common_label(label_hash, phone_main_sym), options[ phone_main_sym ] ),
        options[ phone_hq_sym ]
      ].compact.join(" / "),
      get_composed_field( self.get_common_label(label_hash, phone_fax_sym), options[ phone_fax_sym ] ),
      get_composed_field( self.get_common_label(label_hash, e_mail_sym), options[ e_mail_sym ] ),
      [
        self.get_composed_field( self.get_common_label(label_hash, tax_code_sym), options[ tax_code_sym ] ),
        self.get_composed_field( self.get_common_label(label_hash, vat_registration_sym), options[ vat_registration_sym ] )
      ].compact.join(", ")
    ].compact.join("\n")
  end


  # Draws the banking coordinates on the invoice.
  #
  def self.build_banking_coordinates( options )
    if ( options[:label_hash][:banking_coordinates] &&
         options[:label_hash][:bank_cin_abicab] &&
         options[:label_hash][:bank_cc] )
      "#{options[:label_hash][:banking_coordinates]}: #{(options[:bank_name] ? boldify(options[:bank_name]) : '')}\n" +
      "#{options[:label_hash][:bank_cin_abicab]}: #{options[:bank_cin_abicab]} #{options[:bank_cc]}"
    end
  end


  # Returns the common part of a symbol name to group together same-meaning column symbols,
  # like :+company_phone+ and :+customer_phone+, which may refer to a common localization string (i.e.: "phone").
  # 
  def self.get_common_symbol_part( column_symbol )
    "#{column_symbol}".sub(/company_|customer_/, "").to_sym
  end


  # Returns the label stored inside a labels hash assuming its key symbol could be shared among other columns fields, as in <tt>{ :phone => "Telephone" }</tt> for :+company_phone+ and :+customer_phone+.
  # 
  def self.get_common_label( label_hash, column_symbol )
    label_hash[ self.get_common_symbol_part(column_symbol) ]
  end
  # --------------------------------------------------------------------------
end
