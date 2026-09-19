class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations, id: :uuid do |t|
      t.references :patient_profile, type: :uuid, null: false, foreign_key: true
      t.references :practitioner_profile, type: :uuid, null: false, foreign_key: true
      t.references :appointment, type: :uuid, null: true, foreign_key: true

      t.integer :status, null: false, default: 0
      t.datetime :last_message_at

      t.timestamps
    end

    add_index :conversations, [:patient_profile_id, :practitioner_profile_id], unique: true, name: 'index_conversations_on_patient_and_practitioner'

  end
end
