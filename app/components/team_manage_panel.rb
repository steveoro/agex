#
# Team(s) management composite panel implementation
#
# - author: Steve A.
# - vers. : 3.04.05.20130628
#
class TeamManagePanel < Netzke::Basepack::BorderLayoutPanel

  js_properties(
    :prevent_header => true,
    :header => false,
    :border => true
  )


  def configuration
    super.merge(
      :persistence => true,
      :items => [
        :teams_list.component(
          :region => :center
        ),
        :team_rows_grid.component(
          :region => :south,
          :split => true
        )
      ]
    )
  end
  # ---------------------------------------------------------------------------

  MANAGE_HEADER_HEIGHT = 300                        # this is referenced also more below


  # Overriding initComponent
  js_method :init_component, <<-JS
    function(){
      #{js_full_class_name}.superclass.initComponent.call(this);

      // On each row click we update the both the contacts and the firm detail data:
      var listView = this.getComponent('teams_list').getView();
      listView.on( 'itemclick',
        function( listView, record ) {
          this.selectTeam( {team_id: record.get('id')} );
          this.getComponent( 'team_rows_grid' ).getStore().load();
        },
        this
      );
    }
  JS
  # ---------------------------------------------------------------------------


  endpoint :select_team do |params|
    # store selected team id in the session for this component's instance
    component_session[:selected_team_id] = params[:team_id]
  end


  component :teams_list do
    # ASSERT: assuming current_user is always set for this grid component:
    {
      :class_name => "EntityGrid",
      :height => MANAGE_HEADER_HEIGHT,
      :model => 'Team',
      :prevent_header => true,
      :add_form_window_config => { :width => 650, :title => "#{I18n.t(:add)} #{I18n.t(:team, {:scope=>[:activerecord, :models]})}" },
      :edit_form_window_config => { :width => 650, :title => "#{I18n.t(:edit)} #{I18n.t(:team, {:scope=>[:activerecord, :models]})}" },

# [Steve, 20120208] Scoping the teams on current_user.firm_id does not allow us to manage
#                   and use teams with nil firm_id or owned by a partner firm!
#      :scope => { :firm_id => Netzke::Core.current_user.firm_id },
      # :strong_default_attrs => {
        # :firm_id => Netzke::Core.current_user.firm_id
      # },

      :columns => [
          { :name => :name, :label => I18n.t(:name), :width => 180, :summary_type => :count },
          { :name => :is_no_more_available, :label => I18n.t(:is_no_more_available),
            :default_value => false, :unchecked_value => 'false'
          },
          { :name => :firm__get_full_name, :label => I18n.t(:owner_firm), :width => 200,
            # [Steve, 20120201] (scope definitions can be found inside the Firm model)
            # [20121121] For the combo-boxes to have a working query after the 4th char is entered in the edit widget,
            # a lambda statement must be used. Using a pre-computed scope from the Model class prevents Netzke
            # (as of this version) to append the correct WHERE clause to the scope itself (with an inline lambda, instead, it works).
            :scope => lambda {|rel| rel.team_owners.still_available.order("name ASC")},
            :default_value => Netzke::Core.current_user.firm_id,
            :sorting_scope => :sort_team_by_firm
          },
          { :name => :description, :label => I18n.t(:description), :flex => 1 }
      ]
    }
  end


  component :team_rows_grid do
    {
      :class_name => "TeamRowsGrid",
      :scope => { :team_id => component_session[:selected_team_id] },
#      :min_height => 200,
      :height => config[:height] - MANAGE_HEADER_HEIGHT,

      :strong_default_attrs => {
        :team_id => component_session[:selected_team_id]
      }
    }
  end
  # ---------------------------------------------------------------------------
end
