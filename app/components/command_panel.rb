#
# == Main Command Panel / Menu Toolbar component implementation
#
# - author: Steve A.
# - vers. : 0.25.20121121 (AgeX5 version)
#
require 'netzke/core'


class CommandPanel < Netzke::Basepack::Panel

  action :firms,
    :text => I18n.t(:firms, :scope =>[:agex_action]),
    :tooltip => I18n.t(:firms_tooltip, :scope =>[:agex_action]),
    :icon =>"/images/icons/lorry.png",
    :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_access( :firms )) : true

  action :contacts,
    :text => I18n.t(:contacts, :scope =>[:agex_action]),
    :tooltip => I18n.t(:contacts_tooltip, :scope =>[:agex_action]),
    :icon =>"/images/icons/telephone.png",
    :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_access( :contacts )) : true

  action :human_resources,
    :text => I18n.t(:human_resources, :scope =>[:agex_action]),
    :tooltip => I18n.t(:human_resources_tooltip, :scope =>[:agex_action]),
    :icon =>"/images/icons/group.png",
    :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_access( :human_resources )) : true

  action :teams,
    :text => I18n.t(:teams, :scope =>[:agex_action]),
    :tooltip => I18n.t(:teams_tooltip, :scope =>[:agex_action]),
    :icon =>"/images/icons/group_link.png",
    :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_access( :teams )) : true

  action :projects,
    :text => I18n.t(:projects, :scope =>[:agex_action]),
    :tooltip => I18n.t(:projects_tooltip, :scope =>[:agex_action]),
    :icon =>"/images/icons/database_table.png",
    :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_access( :projects )) : true

  action :accounts,
    :text => I18n.t(:accounts, :scope =>[:agex_action]),
    :tooltip => I18n.t(:accounts_tooltip, :scope =>[:agex_action]),
    :icon =>"/images/icons/folder_table.png",
    :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_access( :accounts )) : true

  action :account_data_import,
    :text => I18n.t(:account_data_import, :scope =>[:agex_action]),
    :tooltip => I18n.t(:account_data_import_tooltip, :scope =>[:agex_action]),
    :icon =>"/images/icons/database_lightning.png",
    :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_access( :accounts )) : true

  action :invoices,
    :text => I18n.t(:invoices, :scope =>[:agex_action]),
    :tooltip => I18n.t(:invoices_tooltip, :scope =>[:agex_action]),
    :icon =>"/images/icons/email_open_image.png",
    :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_access( :invoices )) : true

  action :invoice_analysis,
    :text => I18n.t(:invoice_analysis, :scope =>[:agex_action]),
    :tooltip => I18n.t(:invoice_analysis_tooltip, :scope =>[:agex_action]),
    :icon =>"/images/icons/chart_curve.png",
    :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_access( :invoices )) : true

  action :articles,
    :text => I18n.t(:articles, :scope =>[:agex_action]),
    :tooltip => I18n.t(:articles_tooltip, :scope =>[:agex_action]),
    :icon =>"/images/icons/user_comment.png",
    :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_access( :articles )) : true

  action :users,
    :text => I18n.t(:users, :scope =>[:agex_action]),
    :tooltip => I18n.t(:users_tooltip, :scope =>[:agex_action]),
    :icon =>"/images/icons/user_suit.png",
    :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_access( :users )) : true

  action :app_parameters,
    :text => I18n.t(:app_parameters, :scope =>[:agex_action]),
    :tooltip => I18n.t(:app_parameters_tooltip, :scope =>[:agex_action]),
    :icon =>"/images/icons/wrench_orange.png",
    :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_access( :app_parameters )) : true

  action :setup,
    :text => I18n.t(:sub_entities, :scope =>[:agex_action]),
    :tooltip => I18n.t(:sub_entities_tooltip, :scope =>[:agex_action]),
    :icon =>"/images/icons/table_relationship.png",
    :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_access( :setup )) : true

  action :index,
    :text => I18n.t(:home, :scope =>[:agex_action]),
    :tooltip => I18n.t(:home_tooltip, :scope =>[:agex_action]),
    :icon =>"/images/icons/house_go.png",
    :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_access( :welcome )) : true

  action :about,
    :text => I18n.t(:about, :scope =>[:agex_action]),
    :tooltip => I18n.t(:about_tooltip, :scope =>[:agex_action]),
    :icon =>"/images/icons/information.png"

  action :contact_us,
    :text => I18n.t(:contact_us, :scope =>[:agex_action]),
    :tooltip => I18n.t(:contact_us_tooltip, :scope =>[:agex_action]),
    :icon =>"/images/icons/email.png",
    :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_access( :welcome )) : true

  action :whos_online,
    :text => I18n.t(:whos_online, :scope =>[:agex_action]),
    :tooltip => I18n.t(:whos_online_tooltip, :scope =>[:agex_action]),
    :icon =>"/images/icons/monitor.png",
    :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_do( :welcome, :whos_online )) : true

  action :edit_current_user,
    :text => I18n.t(:edit_current_user, :scope =>[:agex_action]),
    :tooltip => I18n.t(:edit_current_user_tooltip, :scope =>[:agex_action]),
    :icon =>"/images/icons/user_edit.png",
    :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_do( :welcome, :edit_current_user )) : true

  action :logout,
    :text => I18n.t(:logout, :scope =>[:agex_action]),
    :tooltip => I18n.t(:logout_tooltip, :scope =>[:agex_action]),
    :icon =>"/images/icons/door_out.png"
  # ---------------------------------------------------------------------------


  js_property :tbar, [
    {
      :menu => [
        :index.action,
        :about.action,
        :contact_us.action,
        "-",
        :edit_current_user.action,
        "-",
        :logout.action
      ],
      :text => I18n.t(:main, :scope =>[:agex_action]),
      :icon => "/images/icons/application_home.png"
    },
    {
      :menu => [ :firms.action, :contacts.action, "-", :teams.action, :human_resources.action ],
      :text => I18n.t(:firms_and_teams, :scope =>[:agex_action]),
      :icon => "/images/icons/group.png",
      :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_access( :firms )) : true
    },
    {
      :menu => [ :accounts.action, :account_data_import.action, "-", :projects.action, :invoices.action, :invoice_analysis.action ],
      :text => I18n.t(:accounts_projects_and_invoices, :scope =>[:agex_action]),
      :icon => "/images/icons/folder_table.png",
      :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_access( :projects )) : true
    },
    {
      :menu => [ :setup.action ],
      :text => I18n.t(:sub_entities, :scope =>[:agex_action]),
      :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_access( :setup )) : true
    },
    {
      :menu => [ :articles.action, :whos_online.action, "-", :users.action, :app_parameters.action ],
      :text => I18n.t(:manage_system, :scope =>[:agex_action]),
      :icon => "/images/icons/computer.png",
      :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_access( :articles )) : true
    }
  ]



  js_properties(
    :prevent_header => true,
    :header => false
  )


  def configuration
    super.merge(
      :min_height => 28,
#      :width => 1024,
      :height => 28,
      :margin => 0
    )
  end
  # ---------------------------------------------------------------------------


  js_method :init_component, <<-JS
    function(){
      #{js_full_class_name}.superclass.initComponent.call(this);
    }  
  JS
  # ---------------------------------------------------------------------------


  # Front-end JS event handler for the action 'firms' (index)
  #
  js_method :on_firms, <<-JS
    function(){
      location.href = "#{LeUser.new.firms_path()}";
    }
  JS

  # Front-end JS event handler for the action 'contacts' (index)
  #
  js_method :on_contacts, <<-JS
    function(){
      location.href = "#{LeUser.new.contacts_path()}";
    }
  JS

  # Front-end JS event handler for the action 'human_resources' (index)
  #
  js_method :on_human_resources, <<-JS
    function(){
      location.href = "#{LeUser.new.human_resources_path()}";
    }
  JS

  # Front-end JS event handler for the action 'teams' (index)
  #
  js_method :on_teams, <<-JS
    function(){
      location.href = "#{LeUser.new.teams_path()}";
    }
  JS

  # Front-end JS event handler for the action 'projects' (index)
  #
  js_method :on_projects, <<-JS
    function(){
      location.href = "#{LeUser.new.projects_path()}";
    }
  JS

  # Front-end JS event handler for the action 'accounts' (index)
  #
  js_method :on_accounts, <<-JS
    function(){
      location.href = "#{LeUser.new.accounts_path()}";
    }
  JS

  # Front-end JS event handler for the action 'account_data_import' (data_import)
  #
  js_method :on_account_data_import, <<-JS
    function(){
      location.href = "#{LeUser.new.data_import_accounts_path()}";
    }
  JS

  # Front-end JS event handler for the action 'invoices' (index)
  #
  js_method :on_invoices, <<-JS
    function(){
      location.href = "#{LeUser.new.invoices_path()}";
    }
  JS

  # Front-end JS event handler for the action 'invoice_analysis' (analysis)
  #
  js_method :on_invoice_analysis, <<-JS
    function(){
      location.href = "#{LeUser.new.analysis_invoices_path()}";
    }
  JS

  # Front-end JS event handler for the action 'articles' (index)
  #
  js_method :on_articles, <<-JS
    function(){
      location.href = "#{LeUser.new.articles_path()}";
    }
  JS

  # Front-end JS event handler for the action 'users' (index)
  #
  js_method :on_users, <<-JS
    function(){
      location.href = "#{LeUser.new.users_path()}";
    }
  JS

  # Front-end JS event handler for the action 'users' (index)
  #
  js_method :on_app_parameters, <<-JS
    function(){
      location.href = "#{LeUser.new.app_parameters_path()}";
    }
  JS
  # ---------------------------------------------------------------------------

  # Front-end JS event handler for the action 'index' (welcome/index)
  #
  js_method :on_index, <<-JS
    function(){
      location.href = "#{LeUser.new.index_path()}";
    }
  JS

  # Front-end JS event handler for the action 'about' (welcome/about)
  #
  js_method :on_about, <<-JS
    function(){
      location.href = "#{LeUser.new.about_path()}";
    }
  JS

  # Front-end JS event handler for the action 'contact_us' (welcome/contact_us)
  #
  js_method :on_contact_us, <<-JS
    function(){
      location.href = "#{LeUser.new.contact_us_path()}";
    }
  JS

  # Front-end JS event handler for the action 'whos_online' (welcome/whos_online)
  #
  js_method :on_whos_online, <<-JS
    function(){
      location.href = "#{LeUser.new.whos_online_path()}";
    }
  JS

  # Front-end JS event handler for the action 'edit_current_user' (welcome/edit_current_user)
  #
  js_method :on_edit_current_user, <<-JS
    function(){
      location.href = "#{LeUser.new.edit_current_user_path()}";
    }
  JS
  # ---------------------------------------------------------------------------

  # Front-end JS event handler for the action 'setup' (setup)
  #
  js_method :on_setup, <<-JS
    function(){
      location.href = "#{LeUser.new.setup_path()}";
    }
  JS
  # ---------------------------------------------------------------------------

  # Front-end JS event handler for the action 'logout' (login)
  #
  js_method :on_logout, <<-JS
    function(){
      location.href = "#{LeUser.new.logout_path()}";
    }
  JS
  # ---------------------------------------------------------------------------
end
