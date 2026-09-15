class CreateAppointments < ActiveRecord::Migration[8.1]
  def change
    create_table :appointments, id: :uuid do |t|
      t.references :practitioner_profile, type: :uuid, null: false, foreign_key: true
      t.references :patient_profile, type: :uuid, null: false, foreign_key: true

      t.datetime :scheduled_at, null: false
      t.integer :duration, null: false, default: 30
      t.integer :status, null: false, default: 0
      t.text :reason
      t.text :cancellation_reason

      t.timestamps
    end

    add_index :appointments, [:practitioner_profile_id, :scheduled_at]
    add_index :appointments, [:patient_profile_id, :scheduled_at]
    add_index :appointments, :status
  end
end
