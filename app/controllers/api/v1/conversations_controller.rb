# app/controllers/api/v1/conversations_controller.rb
module Api
  module V1
    class ConversationsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_conversation, only: [:show]

      def index
        conversations = Conversation.for_user(current_user)
                                    .includes(:patient_profile, :practitioner_profile)

        render json: { data: ConversationSerializer.new(conversations, current_user).as_json }
      end

      def show
        render json: { data: ConversationSerializer.new(@conversation, current_user, detailed: true).as_json }
      end

      def create
        unless current_user.patient?
          return render json: { errors: ['Seul un patient peut initier une conversation'] }, status: :forbidden
        end

        existing_conversation = Conversation.find_by(
          patient_profile_id: current_user.patient_profile.id,
          practitioner_profile_id: params[:practitioner_profile_id]
        )

        if existing_conversation
          return render  json: { data: ConversationSerializer.new(existing_conversation, current_user).as_json }
        end

        conversation = Conversation.new(
          patient_profile: current_user.patient_profile,
          practitioner_profile_id: params[:practitioner_profile_id],
          initiated_by: :patient
        )

        if conversation.save
          render json: { data: ConversationSerializer.new(conversation, current_user).as_json }, status: :created
        else
          render json: { errors: conversation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_conversation
        @conversation = Conversation.for_user(current_user).find(params[:id])
      end
    end
  end
end
