class FixLastMessageIdTypeOnConversations < ActiveRecord::Migration[8.1]
  def up
    remove_column :conversations, :last_message_id
    add_column :conversations, :last_message_id, :uuid
    add_index :conversations, :last_message_id
    add_foreign_key :conversations, :messages, column: :last_message_id
  end

  def down
    remove_foreign_key :conversations, column: :last_message_id
    remove_column :conversations, :last_message_id
    add_column :conversations, :last_message_id, :datetime
  end
end
