class CreatePractitionerProfilesSpecialities < ActiveRecord::Migration[8.1]
  def change
    create_table :practitioner_profiles_specialities, id: :uuid do |t|
      t.references :practitioner_profile, type: :uuid, null: false
      t.references :speciality, type: :uuid, null: false, foreign_key: true
    end

    add_index :practitioner_profiles_specialities, [ :practitioner_profile_id, :speciality_id ], unique: true, name: "index_practitionner_specialities_unique"
  end
end
