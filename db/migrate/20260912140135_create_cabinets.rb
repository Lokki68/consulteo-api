class CreateCabinets < ActiveRecord::Migration[8.1]
  def change
    create_table :cabinets, id: :uuid do |t|
      t.string :name, null: false
      t.text :address
      t.string :city
      t.string :postal_code
      t.float :latitude
      t.float :longitude
      t.string :phone_number

      t.timestamps
    end

    add_index :cabinets, [:latitude, :longitude]
    add_index :cabinets, :city
  end
end
