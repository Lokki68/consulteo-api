class AddCabinetToPractitionerProfiles < ActiveRecord::Migration[8.1]
  def change
    add_reference :practitioner_profiles, :cabinet, null: true, foreign_key: true, type: :uuid
  end
end
