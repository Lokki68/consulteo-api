class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages, id: :uuid do |t|
      t.references :conversation, type: :uuid, null: false, foreign_key: true
      t.references :sender, type: :uuid, null: false, foreign_key: { to_table: :users }

      t.text :content, null: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :messages, [:conversation_id, :created_at]
    add_index :messages, :read_at
  end
end
