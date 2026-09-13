class CreateAvailabilityExceptions < ActiveRecord::Migration[8.1]
  def change
    create_table :availability_exceptions, id: :uuid do |t|
      t.references :practitioner_profile, type: :uuid, null: false, foreign_key: true

      t.date :date, null: false
      t.integer :exception_type, null: false, default: 0

      t.time :start_time
      t.time :end_time

      t.string :reason

      t.timestamps
    end

    add_index :availability_exceptions, [:practitioner_profile_id, :date]
  end
end
