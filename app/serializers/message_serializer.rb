# app/serializers/message_serializer.rb
class MessageSerializer
  def initialize(message)
    @message = message
  end

  def as_json
    {
      id: @message.id,
      conversation_id: @message.conversation_id,
      sender_id: @message.sender_id,
      content: @message.content,
      read_at: @message.read_at&.iso8601,
      created_at: @message.created_at.iso8601
    }
  end

  private

  attr_reader :message
end