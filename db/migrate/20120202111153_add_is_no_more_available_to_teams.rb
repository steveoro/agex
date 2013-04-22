class AddIsNoMoreAvailableToTeams < ActiveRecord::Migration
  def up
    add_column :teams, :is_no_more_available, :boolean, :default => false
  end

  def down
    remove_column :teams, :is_no_more_available
  end
end
