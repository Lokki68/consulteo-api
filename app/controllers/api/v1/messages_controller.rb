class Api::V1::MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation

  def create
    message = @conversation.messages.new(message_params.merge(sender: current_user))

    if message.save
      render json: MessageSerializer.new(message).as_json, status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def mark_as_read
    @conversation.messages.where.not(sender: current_user).update_all(read_at: Time.current)
    head :no_content
  end

  private

  def set_conversation
    @conversation = Conversation.for_user(current_user).find(params[:conversation_id])
  end

  def message_params
    params.require(:message).permit(:content)
  end
end