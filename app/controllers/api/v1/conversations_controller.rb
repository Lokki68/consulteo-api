# app/controllers/api/v1/conversations_controller.rb
module Api
  module V1
    class ConversationsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_conversation, only: [:show]
      before_action :authorize_patient!, only: [:create]

      def index
        conversations = current_user.conversations
                                    .includes(:patient_profile, :practitioner_profile)
                                    .order(updated_at: :desc)

        render json: {
          data: ConversationSerializer.new(conversations).as_json
        }
      end

      def show
        render json: {
          data: ConversationSerializer.new(
            @conversation,
            params: {
              current_user: current_user
            }
          ).as_json
        }
      end

      def create
        existing_conversation = find_or_create_conversation
        status_code = existing_conversation.newly_created? ? :created : :ok

        render json: {
          data: ConversationSerializer.new(
            existing_conversation,
            params: { current_user: current_user }
          ).as_json,
          message: "Conversation #{status_code == :created ? 'created' : 'retrieved' } successfully"
        }, status: status_code
      end

      private

      def authorize_patient!
        render json: {
          errors: ['Seul un patient peu initier une conversation']
        }, status: :forbidden unless current_user.patient?
      end

      def find_or_create_conversation
        conversation = Conversation.find_by(
          patient_profile_id: current_user.patient_profile.id,
          practitioner_profile_id: conversation_params[:practitioner_profile_id]
        )

        return conversation if conversation.present?

        create_conversation
      end

      def create_conversation
        conversation = current_user.patient_profile.conversatoins.build(
          practitioner_profile_id: conversation_params[:practitioner_profile_id],
          initiated_by: :patient
        )

        if conversation.save
          conversation
        else
          render json: {
            errors: conversation.errors.full_messages
          }, status: :unprocessable_entity
          nil
        end
      end

      def set_conversation
        @conversation = Conversation.for_user(current_user).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { errors: 'Conversaton not found' }, status: :not_found
      end

      def conversation_params
        params.require(:conversation).permit(:practitioner_profile_id)
      end
    end
  end
end
