class RemoveGlobalizeTables < ActiveRecord::Migration
  def up
    drop_table :globalize_countries
    drop_table :globalize_languages
    drop_table :globalize_translations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
