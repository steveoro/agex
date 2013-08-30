class HumanResourcesController < ApplicationController

  # Require authorization before invoking any of this controller's actions:
  before_filter :authorize


  # Default action
  def index
    ap = AppParameter.get_parameter_row_for( :human_resources )
    @max_view_height = ap.get_view_height()
    @context_title = I18n.t(:human_resources_list)
  end
  # ---------------------------------------------------------------------------

end
