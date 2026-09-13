class CreatePatientProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :patient_profiles, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true, index: { unique: true }

      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :date_of_birth
      t.string :phone_number

      t.text :address
      t.string :city
      t.string :postal_code
      t.float :latitude
      t.float :longitude

      t.string :social_security_number_ciphertext
      t.string :social_security_number_bidx #blind index pour recherche

      t.timestamps
    end

    add_index :patient_profiles, :social_security_number_bidx, unique: true
    add_index :patient_profiles, [:latitude, :longitude]
  end
end
