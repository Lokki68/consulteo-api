class CreateAvailabilities < ActiveRecord::Migration[8.1]
  def change
    create_table :availabilities, id: :uuid do |t|
      t.references :practitioner_profile, type: :uuid, null: false, foreign_key: true

      t.integer :day_of_week, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false

      t.timestamps
    end

    add_index :availabilities, [ :practitioner_profile_id, :day_of_week ]
  end
end
