class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: "User"

  validates :content, presence: true

  scope :unread_for, ->(user) { where.not(sender_id: user.id).where(read_at: nil) }

  after_create_commit :broadcast_message
  after_create_commit :touch_conversation_last_message_at

  private

  def touch_conversation_last_message_at
    conversation.update_column(:last_message_at, created_at)
  end

  def broadcast_message
    ConversationChannel.broadcast_to(
      conversation,
      type: "message",
      message: MessageSerializer.new(self).as_json
    )
  end
end
