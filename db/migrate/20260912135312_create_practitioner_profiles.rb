class CreatePractitionerProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :practitioner_profiles, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true, index: { unique: true }

      t.string :first_name, null: false
      t.string :last_name, null: false
      t.text :bio

      t.string :rpps_number
      t.boolean :verified, default: false

      t.integer :sector, default: 0
      t.integer :consultation_price_cents

      t.timestamps
    end

    add_index :practitioner_profiles, :rpps_number, unique: true
  end
end
