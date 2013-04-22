#
# Specialized Account list/grid component implementation
#
# - author: Steve A.
# - vers. : 0.25.20120912
#
class AccountsList < MacroEntityGrid

  model 'Account'
  js_property :target_for_ctrl_manage, Netzke::Core.controller.manage_account_path( :locale => I18n.locale, :id => -1 )

  add_form_window_config  :width => 600, :title => "#{I18n.t(:add_account)}"
  edit_form_window_config :width => 600, :title => "#{I18n.t(:edit_account)}"
  # ---------------------------------------------------------------------------


  def configuration
    # ASSERT: assuming current_user is always set for this grid component:
    super.merge(
      :scope => { :firm_id => Netzke::Core.current_user.firm_id },
      # [20120221] This field is required by model, but we are silently filtering by the firm, so we use
      # a strong default to enforce its value:
      :strong_default_attrs => {
          :firm_id => Netzke::Core.current_user.firm_id
      },
      :columns => [
          { :name => :created_on, :label => I18n.t(:created_on), :width => 80,  :read_only => true,
            :format => 'Y-m-d', :summary_type => :count },
          { :name => :updated_on, :label => I18n.t(:updated_on), :width => 120, :read_only => true,
            :format => 'Y-m-d' },
          { :name => :name,        :label => I18n.t(:name) },
          { :name => :description, :label => I18n.t(:description), :flex => 1 }
      ]
    )
  end
  # ---------------------------------------------------------------------------
end
