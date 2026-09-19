class UnreadMessagesMailer < ApplicationMailer
  def reminder(message, recipient)
    @message = message
    @recipient = recipient
    @conversation = message.conversation

    mail(to: recipient.email, subject: "Vous avez un message non lu")
  end
end