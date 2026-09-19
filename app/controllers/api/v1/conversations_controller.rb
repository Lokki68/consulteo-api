# app/controllers/api/v1/conversations_controller.rb
module Api
  module V1
    class ConversationsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_conversation, only: [:show]

      def index
        conversations = Conversation.for_user(current_user)
                                    .includes(:patient_profile, :practitioner_profile)

        render json: ConversationSerializer.new(conversations, current_user).as_json
      end

      def show
        render json: ConversationSerializer.new(@conversation, current_user, detailed: true).as_json
      end

      def create
        conversation = build_conversation

        if conversation.save
          render json: ConversationSerializer.new(conversation, current_user).as_json, status: :created
        else
          render json: { errors: conversation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def build_conversation
        if current_user.patient?
          Conversation.new(
            patient: current_user,
            practitioner_profile_id: params[:practitioner_profile_id]
          )
        else
          Conversation.new(
            patient_id: params[:patient_id],
            practitioner_profile: current_user.practitioner_profile
          )
        end
      end

      def set_conversation
        @conversation = Conversation.for_user(current_user).find(params[:id])
      end
    end
  end
end