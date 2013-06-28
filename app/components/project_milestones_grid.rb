#
# Specialized Project rows list/grid component implementation
#
# - author: Steve A.
# - vers. : 3.04.05.20130628
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
          # [20121121] For the combo-boxes to have a working query after the 4th char is entered in the edit widget,
          # a lambda statement must be used. Using a pre-computed scope from the Model class prevents Netzke
          # (as of this version) to append the correct WHERE clause to the scope itself (with an inline lambda, instead, it works).
          :scope => lambda { |rel| rel.order("name ASC") },
          :sorting_scope => :sort_project_milestone_by_user
        },
        { :name => :human_resource__get_full_name,  :label => I18n.t(:human_resource__get_full_name),
          # [20121121] See note above for the sorted combo boxes.
          :scope => lambda { |rel|
            rel.joins(:team_rows).still_available.where( ['team_id = ?', super[:current_team_id]] ).order("name ASC")
          },
          :default_value => super[:default_human_resource_id], :sorting_scope => :sort_project_milestone_by_resource
        },
        { :name => :name, :label => I18n.t(:name), :width => 150 },
        { :name => :depends_on__name, :label => I18n.t(:depends_on__name), :width => 65,
          # [20121121] See note above for the sorted combo boxes.
          :scope => lambda { |rel| rel.order("name ASC") },
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

        { :name => :module_names, :label => I18n.t(:module_names),:width => 180 },
        { :name => :date_implemented, :xtype => :datecolumn, :label => I18n.t(:date_implemented), :width => 80,
          :format => 'Y-m-d' },
        { :name => :implemented_in_version, :label => I18n.t(:implemented_in_version), :width => 70,
          :default_value => ''
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


  # Override default fields for forms. Must return an array understood by the
  # items property of the forms.
  #
  def default_fields_for_forms
    [
      { :name => :created_on, :field_label => I18n.t(:created_on), :width => 80,   :read_only => true,
        :format => 'Y-m-d' },
      { :name => :updated_on, :field_label => I18n.t(:updated_on), :width => 120,  :read_only => true,
        :format => 'Y-m-d' },

      { :name => :user__name, :field_label => I18n.t(:user), :width => 70, :default_value => Netzke::Core.current_user.id,
        # [20121121] For the combo-boxes to have a working query after the 4th char is entered in the edit widget,
        # a lambda statement must be used. Using a pre-computed scope from the Model class prevents Netzke
        # (as of this version) to append the correct WHERE clause to the scope itself (with an inline lambda, instead, it works).
        :scope => lambda { |rel| rel.order("name ASC") }
      },
      { :name => :human_resource__get_full_name,  :field_label => I18n.t(:human_resource__get_full_name),
          # [20121121] See note above for the sorted combo boxes.
        :scope => lambda { |rel|
          rel.joins(:team_rows).still_available.where( ['team_id = ?', config[:current_team_id]] ).order("name ASC")
        },
        :default_value => config[:default_human_resource_id]
      },
      { :name => :depends_on__name, :field_label => I18n.t(:depends_on__name), :width => 65,
        # [20121121] See note above for the sorted combo boxes.
        :scope => lambda { |rel| rel.order("name ASC") }
      },
      { :name => :esteemed_days, :field_label => I18n.t(:esteemed_days), :width => 60,
        :summary_type => :sum
      },
      { :name => :date_esteemed, :field_label => I18n.t(:date_esteemed),
        :width => 75, :format => 'Y-m-d'
      },
      { :name => :projected_for_version, :field_label => I18n.t(:projected_for_version), :width => 80 },

      { :name => :is_public, :field_label => I18n.t(:is_public),
        :default_value => false, :unchecked_value => 'false'
      },
      { :name => :is_critical, :field_label => I18n.t(:is_critical),
        :default_value => false, :unchecked_value => 'false'
      },
      { :name => :is_urgent, :field_label => I18n.t(:is_urgent),
        :default_value => false, :unchecked_value => 'false'
      },
      { :name => :is_structural, :field_label => I18n.t(:is_structural),
        :default_value => false, :unchecked_value => 'false'
      },
      { :name => :is_user_request, :field_label => I18n.t(:is_user_request),
        :default_value => false, :unchecked_value => 'false'
      },
      { :name => :name, :field_label => I18n.t(:name), :width => 150 },
      { :name => :module_names, :field_label => I18n.t(:module_names),:width => 180 },
      { :name => :date_implemented, :field_label => I18n.t(:date_implemented),
        :width => 80, :format => 'Y-m-d'
      },
      { :name => :implemented_in_version, :field_label => I18n.t(:implemented_in_version),
        :width => 70, :default_value => ''
      },
      { :name => :description, :field_label => I18n.t(:description), :width => 300 },
      { :name => :notes, :field_label => I18n.t(:notes), :width => 300 }
    ]
  end
  # ---------------------------------------------------------------------------
end
