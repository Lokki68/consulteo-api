class Api::V1::MessagesController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_user!
  before_action :set_conversation

  def index
    pagy, messages = pagy(
      @conversation.messages.order(created_at: :asc),
      items: params[:per_page] || 30
    )

    render json: {
      data: MessageSerializer.new(messages).as_json,
      pagination: {
        current_page: pagy.page,
        total_pages: pagy.pages,
        total_count: pagy.count
      }
    }
  end

  def create
    message = @conversation.messages.new(
      message_params.merge(sender: current_user)
    )

    if message.save
      render json: {
        data: MessageSerializer.new(message).as_json
      }, status: :created
    else
      render json: {
        errors: message.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def mark_as_read
    message_ids = params[:message_ids] || []

    @conversation.messages
                 .where(id: message_ids)
                 .where.not(sender: current_user)
                 .update_all(read_at: Time.current)

    render json: {
      data: message_ids,
      message: 'Messages marked as read sucessfully'
    }
  end

  private

  def set_conversation
    @conversation = Conversation.for_user(current_user).find(params[:conversation_id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      errors: 'Conversation not found'
    }, status: :not_found
  end

  def message_params
    params.require(:message).permit(:content)
  end
end