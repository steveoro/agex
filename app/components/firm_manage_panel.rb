#
# Firms management composite panel implementation
#
# - author: Steve A.
# - vers. : 3.03.14.20130419
#
class FirmManagePanel < Netzke::Basepack::BorderLayoutPanel

  js_properties(
    :prevent_header => true,
    :header => false,
    :border => true
  )


  def configuration
    super.merge(
      :persistence => true,
      :items => [
        :firms_list.component(
          :region => :center
        ),
        :firm_details.component(
          :region => :east,
          :split => true
        ),
        :contacts.component(
          :region => :south,
#          :min_height => 100,
          :height => 200,
          :split => true
        )
      ]
    )
  end


  # Overriding initComponent
  js_method :init_component, <<-JS
    function(){
      // calling superclass's initComponent
//      this.callParent();
      // Another - more convolute way - to call superclass's initComponent:
      #{js_full_class_name}.superclass.initComponent.call(this);

      // On each row click we update the both the contacts and the firm detail data:
      var listView = this.getComponent('firms_list').getView();

      listView.on( 'itemclick', function( listView, record ) {
          // The beauty of using Ext.Direct: calling 3 endpoints in a row, which results in a single call to the server!
          this.selectFirm( {firm_id: record.get('id')} );
          this.getComponent( 'contacts' ).getStore().load();
          // [Steve, 20120207] As of this version, netzkeLoad does not clear the previous form data for nil fields.
                                                    // Let's clear all the fields, since all possible nil column will be stripped out of the hash and won't be updated in the return data
          var firmDetailsFrm = this.getComponent( 'firm_details' );
          firmDetailsFrm.getForm().getFields().each( function(fld){ fld.setValue(); } );
                                                    // Now that the form is cleared out, load the data:
          firmDetailsFrm.netzkeLoad( {id: record.get('id')} );
        },
        this
      );
    }
  JS
  # ---------------------------------------------------------------------------


  endpoint :select_firm do |params|
    # store selected firm id in the session for this component's instance
    component_session[:selected_firm_id] = params[:firm_id]
  end


  component :firms_list do
    {
      :class_name => "FirmsList"
    }
  end


  component :firm_details do
    {
      :class_name => "FirmDetails",
      :title => I18n.t(:firm_details),
      :mode => :lockable,
      :record_id => component_session[:selected_firm_id]
# FIXME
#      :strong_default_attrs => {
#        :le_currency_id => AppParameter.get_default_currency_id()
#      }
    }
  end


  component :contacts do
    {
      :class_name => "ContactsList",
      :title => I18n.t(:contacts_x_firm),
      :load_inline_data => false,
      :scope => { :firm_id => component_session[:selected_firm_id] },
      :strong_default_attrs => {
        :firm_id => component_session[:selected_firm_id]
      }
    }
  end
  # ---------------------------------------------------------------------------
end
