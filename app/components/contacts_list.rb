#
# Specialized Contact list/grid component implementation
#
# - author: Steve A.
# - vers. : 3.03.14.20130419
#
class ContactsList < EntityGrid

  model 'Contact'
  # ---------------------------------------------------------------------------


  def configuration
    super.merge(
      :prevent_header => true,
      :persistence => true,

      :add_form_window_config => { :height => 600, :width => 500, :title => "#{I18n.t(:add_contact_row)}" },
      :edit_form_window_config => { :height => 600, :width => 500, :title => "#{I18n.t(:edit_contact_row)}" },

      :columns => [
          { :name => :le_title__get_full_name, :label => I18n.t(:le_title, {:scope=>[:activerecord, :models]}),
            :sorting_scope => :sort_contact_by_title, :summary_type => :count },
          { :name => :name, :label => I18n.t(:name) },
          { :name => :surname, :label => I18n.t(:surname) },
          { :name => :le_contact_type__get_full_name, :label => I18n.t(:le_contact_type, {:scope=>[:activerecord, :models]}),
            :sorting_scope => :sort_contact_by_type },
          { :name => :is_suspended,   :label => I18n.t(:is_suspended),
            :default_value => false, :unchecked_value => 'false'
          },
          { :name => :address, :label => I18n.t(:address) },
          { :name => :le_city__get_full_name, :label => I18n.t(:le_city, {:scope=>[:activerecord, :models]}),
            :sorting_scope => :sort_contact_by_city },
          { :name => :tax_code, :label => I18n.t(:tax_code) },
          { :name => :vat_registration, :label => I18n.t(:vat_registration) },
          { :name => :date_birth,     :label => I18n.t(:date_birth) },
          { :name => :phone_home,     :label => I18n.t(:phone_home) },
          { :name => :phone_work,     :label => I18n.t(:phone_work) },
          { :name => :phone_cell,     :label => I18n.t(:phone_cell) },
          { :name => :phone_fax,      :label => I18n.t(:phone_fax) },
          { :name => :e_mail,         :label => I18n.t(:e_mail) },

          { :name => :date_last_met,  :label => I18n.t(:date_last_met) },
          { :name => :notes,          :label => I18n.t(:notes), :width => 200 },
          { :name => :personal_notes, :label => I18n.t(:personal_notes), :width => 200 },
          { :name => :family_notes,   :label => I18n.t(:family_notes), :width => 200 }
      ],
      :border => true,
      :view_config => {
        :force_fit => true # force the columns to occupy all the available width
      }
    )
  end


  js_method :init_component, <<-JS
    function(){
      // Another - more convolute way - to call superclass's initComponent:
      #{js_full_class_name}.superclass.initComponent.call(this);
                                                    // As soon as the grid is ready, sort it by default:
      this.on( 'viewready',
        function( gridPanel, eOpts ) {
          gridPanel.store.sort([ { property: 'surname', direction: 'ASC' } ]);
        },
        this
      );
    }  
  JS
  # ---------------------------------------------------------------------------


  # Override default fields for forms. Must return an array understood by the
  # items property of the forms.
  #
  def default_fields_for_forms
    [
      { :name => :le_title__get_full_name, :field_label => I18n.t(:le_title, {:scope=>[:activerecord, :models]})
      },
      { :name => :name,           :field_label => I18n.t(:name) },
      { :name => :surname,        :field_label => I18n.t(:surname) },
      { :name => :le_contact_type__get_full_name, :field_label => I18n.t(:le_contact_type, {:scope=>[:activerecord, :models]}),
        :sorting_scope => :sort_contact_by_type
      },
      { :name => :is_suspended,   :field_label => I18n.t(:is_suspended),
        :default_value => false, :unchecked_value => 'false'
      },
      { :name => :address,        :field_label => I18n.t(:address) },
      { :name => :le_city__get_full_name, :field_label => I18n.t(:le_city, {:scope=>[:activerecord, :models]}),
        :sorting_scope => :sort_contact_by_city },
      { :name => :tax_code,       :field_label => I18n.t(:tax_code) },
      { :name => :vat_registration, :field_label => I18n.t(:vat_registration) },
      { :name => :date_birth,     :field_label => I18n.t(:date_birth) },
      { :name => :phone_home,     :field_label => I18n.t(:phone_home) },
      { :name => :phone_work,     :field_label => I18n.t(:phone_work) },
      { :name => :phone_cell,     :field_label => I18n.t(:phone_cell) },
      { :name => :phone_fax,      :field_label => I18n.t(:phone_fax) },
      { :name => :e_mail,         :field_label => I18n.t(:e_mail) },

      { :name => :date_last_met,  :field_label => I18n.t(:date_last_met) },
      { :name => :notes,          :field_label => I18n.t(:notes), :width => 200 },
      { :name => :personal_notes, :field_label => I18n.t(:personal_notes), :width => 200 },
      { :name => :family_notes,   :field_label => I18n.t(:family_notes), :width => 200 }
    ]
  end
  # ---------------------------------------------------------------------------
end
