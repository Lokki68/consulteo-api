class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find_by(id: params[:conversation_id])

    unless authorized?(conversation)
      reject
      return
    end

    stream_for conversation
    current_user.go_online!
    broadcast_presence(conversation, online: true)
  end

  def unsubscribed
    current_user.go_offline!
    conversation = Conversation.find_by(id: params[:conversation_id])
    broadcast_presence(conversation, online: false) if conversation
  end

  private

  def authorized?(conversation)
    return false unless conversation

    patient_user_id = conversation.patient_profile.user_id
    practitioner_user_id = conversation.practitioner_profile.user_id

    current_user.id == patient_user_id || current_user.id == practitioner_user_id
  end

  def broadcast_presence(conversation, online:)
    ConversationChannel.broadcast_to(
      conversation,
      type: 'presence',
      user_id: current_user.id,
      online: online
    )
  end
end