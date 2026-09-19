# app/serializers/conversation_serializer.rb
class ConversationSerializer
  def initialize(conversations, current_user, detailed: false)
    @conversations = conversations
    @current_user = current_user
    @detailed = detailed
  end

  def as_json
    if @conversations.respond_to?(:map)
      @conversations.map { |c| serialize(c) }
    else
      serialize(@conversations)
    end
  end

  private

  def serialize(conversation)
    other = conversation.other_participant(@current_user)

    base = {
      id: conversation.id,
      other_participant: {
        id: other.id,
        full_name: other.full_name,
        online: other.online
      },
      last_message: last_message_json(conversation),
      unread_count: conversation.messages.unread_for(@current_user).count,
      updated_at: conversation.updated_at.iso8601
    }

    @detailed ? base.merge(messages: messages_json(conversation)) : base
  end

  def last_message_json(conversation)
    msg = conversation.last_message
    return nil unless msg

    {
      content: msg.content,
      sender_id: msg.sender_id,
      created_at: msg.created_at.iso8601,
      read_at: msg.read_at&.iso8601
    }
  end

  def messages_json(conversation)
    conversation.messages.order(:created_at).map do |m|
      MessageSerializer.new(m).as_json
    end
  end
end