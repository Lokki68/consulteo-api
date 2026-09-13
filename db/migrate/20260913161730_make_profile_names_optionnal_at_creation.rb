class MakeProfileNamesOptionnalAtCreation < ActiveRecord::Migration[8.1]
  def change
    change_column_null :patient_profiles, :first_name, true
    change_column_null :patient_profiles, :last_name, true
    change_column_null :practitioner_profiles, :first_name, true
    change_column_null :practitioner_profiles, :last_name, true
  end
end
