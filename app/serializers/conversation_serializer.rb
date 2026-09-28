# app/serializers/conversation_serializer.rb
class ConversationSerializer
  include Alba::Resource

  attributes :id, :status, :created_at, :last_message_at

  attribute :other_participant do |conversation, params|
    current_user = params[:current_user]
    other_user = conversation.other_participant(current_user)
    profile = other_user.patient? ? other_user.patient_profile : other_user.practitioner_profile

    {
      id: other_user.id,
      full_name: "#{profile.first_name} #{profile.last_name}",
      online: other_user.online,
    }
  end

  attribute :last_message do |conversation|
    msg = conversation.last_message
    next nil unless msg

    MessageSerializer.new(msg).as_json
  end

  attribute :unread_count do |conversation, params|
    current_user = params[:current_user]
    conversation.messages.unread_for(current_user).count
  end
end