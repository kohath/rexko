class TranslatePhoneticForms < ActiveRecord::Migration
  def up
    PhoneticForm.create_translation_table!({
      form:                 :string
    }, { migrate_data: true })
  end

  def down
    PhoneticForm.drop_translation_table! migrate_data: true
  end
end
