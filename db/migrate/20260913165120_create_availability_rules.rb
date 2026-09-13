class CreateAvailabilityRules < ActiveRecord::Migration[8.1]
  def change
    create_table :availability_rules, id: :uuid do |t|
      t.references :practitioner_profile, type: :uuid, null: false, foreign_key: true

      t.integer :day_of_week, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.integer :slot_duration_minutes, null: false, default: 30

      t.date :valid_from, null: false
      t.date :valid_until

      t.boolean :active, default: true

      t.timestamps
    end

    add_index :availability_rules, [ :practitioner_profile_id, :day_of_week ]
    add_check_constraint :availability_rules, "start_time < end_time", name: 'start_before_end_check'
  end
end
