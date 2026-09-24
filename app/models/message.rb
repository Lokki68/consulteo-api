class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: "User"

  validates :content, presence: true

  scope :unread_for, ->(user) { where.not(sender_id: user.id).where(read_at: nil) }

  after_create_commit :broadcast_message

  private

  def broadcast_message
    ConversationChannel.broadcast_to(
      conversation,
      type: "message",
      message: MessageSerializer.new(self).as_json
    )
  end
end
