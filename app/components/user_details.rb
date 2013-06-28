#
# Specialized User details form component implementation
#
# - author: Steve A.
# - vers. : 3.04.05.20130628 (AgeX5 version: users belong to firms)
#
class UserDetails < Netzke::Basepack::FormPanel

  model 'LeUser'

  js_properties(
    :prevent_header => true,
    :border => false
  )


  def configuration
    super.merge(
      :min_width => 480,
      :height => 270,
      :strong_default_attrs => {
        :user_id => Netzke::Core.current_user.id
      }
    )
  end


  items [
    {
      :layout => :column, :border => false, :column_width => 1.0,
      :items => [
        {
          :xtype => :fieldcontainer, :field_label => I18n.t(:created_slash_updated_at),
          :layout => :hbox, :label_width => 150, :width => 400, :height => 18,
          :items => [
            { :name => :created_on,    :hide_label => true, :xtype => :displayfield, :width => 80},
            { :xtype => :displayfield, :value => ' / ',     :margin => '0 2 0 2' },
            { :name => :updated_on,    :hide_label => true, :xtype => :displayfield, :width => 120 }
          ]
        },
        { :name => :name, :field_label => I18n.t(:name), :width => 370, :field_style => 'font-size: 110%; font-weight: bold;' },
        { :name => :description,          :field_label => I18n.t(:description), :width => 400 },

        { :name => :authorization_level,  :field_label => I18n.t(:authorization_level),
          :min_value => 1, :max_value => ( Netzke::Core.current_user ? Netzke::Core.current_user.authorization_level : 1),
          :disabled => Netzke::Core.current_user ? (! Netzke::Core.current_user.can_access( :users )) : true },

        { :name => :password,             :field_label => I18n.t(:password),
          :input_type => :password,       :allow_blank => false },
        { :name => :password_confirmation,:field_label => I18n.t(:password_confirmation),
          :input_type => :password,       :allow_blank => false },

        { :name => :firm__get_full_name, :label => I18n.t(:user_firm), :width => 400,
          # [20121121] For the combo-boxes to have a working query after the 4th char is entered in the edit widget,
          # a lambda statement must be used. Using a pre-computed scope from the Model class prevents Netzke
          # (as of this version) to append the correct WHERE clause to the scope itself (with an inline lambda, instead, it works).
          :scope => lambda {|rel| rel.house_firms.order("name ASC")},
          :scope => :sort_firm_by_verbose_name },

        { :name => :hashed_pwd,           :field_label => I18n.t(:hashed_pwd),
          :xtype => :displayfield,        :width => 400 },
        { :name => :salt,                 :field_label => I18n.t(:salt),
          :xtype => :displayfield,        :width => 400 }
      ]
    }
  ]

  # ---------------------------------------------------------------------------
end
