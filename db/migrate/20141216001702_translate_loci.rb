class TranslateLoci < ActiveRecord::Migration
  def up
    Locus.create_translation_table!({
      example:              :text,
      example_translation:  :text
    }, { migrate_data: true })
  end

  def down
    Locus.drop_translation_table! migrate_data: true
  end
end
