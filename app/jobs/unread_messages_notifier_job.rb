class UnreadMessagesNotifierJob < ApplicationJob
  queue_as :default

  def perform
    Message.stale_unread.find_each do |message|
      recipient = recipient_for(message)
      next unless recipient

      UnreadMessagesMailer.reminder(message, recipient).deliver_later
      message.update_column(:unread_notified_at, Time.current)
    end
  end

  private

  def recipient_for(message)
    conversation = message.conversation

    if message.sender_id == conversation.patient_profile.user_id
      conversation.practitioner_profile.user
    else
      conversation.patient_profile.user
    end
  end
end