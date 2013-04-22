#
# Specialized Project rows list/grid component implementation
#
# - author: Steve A.
# - vers. : 3.03.15.20130422
#
# == Params
#
# :+project_id+ must be set during component configuration and must point to the current header's Project.id
# :+current_team_id+ must point to the default team id set in the Project's header
# :+default_currency_id+ must point to the default currency id that has to be used
# :+default_human_resource_id+ must point to the default human resource id that has to be used
#
class ProjectMilestonesGrid < EntityGrid

  model 'ProjectMilestone'

  add_form_window_config  :width => 600, :title => "#{I18n.t(:add_project_milestone)}"
  edit_form_window_config :width => 600, :title => "#{I18n.t(:edit_project_milestone)}"


  def configuration
    # ASSERT: assuming current_user is always set for this grid component:
    super.merge(
      :persistence => true,
      # [Steve, 20120131]
      # FIXME The Netzke endpoint, once configured, ignores any subsequent request to turn off or resize the pagination
      # TODO Either wait for a new Netzke release that changes this behavior, or rewrite from scratch the endpoint implementation for the service of grid data retrieval
      :enable_pagination => false,
      :prevent_header => true,
      :min_width => 750,
      :columns => [
          { :name => :created_on, :label => I18n.t(:created_on), :width => 80,   :read_only => true,
            :format => 'Y-m-d' },
          { :name => :updated_on, :label => I18n.t(:updated_on), :width => 120,  :read_only => true,
            :format => 'Y-m-d' },

          { :name => :user__name, :label => I18n.t(:user), :width => 70, :default_value => Netzke::Core.current_user.id,
            :sorting_scope => :sort_project_milestone_by_user
          },
          { :name => :human_resource__get_full_name,  :label => I18n.t(:human_resource__get_full_name),
            :scope => lambda { |rel|
              rel.joins(:team_rows).still_available.where( ['team_id = ?', super[:current_team_id]] )
            },
            :default_value => super[:default_human_resource_id], :sorting_scope => :sort_project_milestone_by_resource
          },
          { :name => :depends_on__name, :label => I18n.t(:depends_on__name), :width => 65,
            :sorting_scope => :sort_project_milestone_by_dependency
          },
          { :name => :esteemed_days, :label => I18n.t(:esteemed_days), :width => 60, :summary_type => :sum },
          { :name => :date_esteemed, :xtype => :datecolumn, :label => I18n.t(:date_esteemed),:width => 75,
            :format => 'Y-m-d' },
          { :name => :projected_for_version, :label => I18n.t(:projected_for_version), :width => 80 },

          { :name => :is_public,       :label => I18n.t(:is_public),
            :default_value => false, :unchecked_value => 'false'
          },
          { :name => :is_critical,     :label => I18n.t(:is_critical),
            :default_value => false, :unchecked_value => 'false'
          },
          { :name => :is_urgent,       :label => I18n.t(:is_urgent),
            :default_value => false, :unchecked_value => 'false'
          },
          { :name => :is_structural,   :label => I18n.t(:is_structural),
            :default_value => false, :unchecked_value => 'false'
          },
          { :name => :is_user_request, :label => I18n.t(:is_user_request),
            :default_value => false, :unchecked_value => 'false'
          },

          { :name => :name, :label => I18n.t(:name), :width => 150 },
          { :name => :module_names, :label => I18n.t(:module_names),:width => 180 },
          { :name => :date_implemented, :xtype => :datecolumn, :label => I18n.t(:date_implemented), :width => 80,
            :format => 'Y-m-d' },
          { :name => :implemented_in_version, :label => I18n.t(:implemented_in_version), :width => 70,
            :default_value => false, :unchecked_value => 'false'
          },

          { :name => :description, :label => I18n.t(:description), :width => 300 },
          { :name => :notes, :label => I18n.t(:notes), :width => 300 }
      ]
    )
  end
  # ---------------------------------------------------------------------------


  js_method :init_component, <<-JS
    function(){
      #{js_full_class_name}.superclass.initComponent.call(this);
    }  
  JS

  # ---------------------------------------------------------------------------
end
