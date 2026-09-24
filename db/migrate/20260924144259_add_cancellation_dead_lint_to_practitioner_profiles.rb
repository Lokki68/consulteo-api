class AddCancellationDeadLintToPractitionerProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :practitioner_profiles, :cancellation_deadline_hours, :integer, default: 24, null: false
  end
end
