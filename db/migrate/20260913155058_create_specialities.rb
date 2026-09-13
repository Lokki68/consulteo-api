class CreateSpecialities < ActiveRecord::Migration[8.1]
  def change
    create_table :specialities, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :specialities, :slug, unique: true
  end
end
