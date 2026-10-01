# spec/integration/api/v1/messages_spec.rb
require 'swagger_helper'

RSpec.describe 'Messages API', type: :request do
  path '/api/v1/conversations/{conversation_id}/messages' do
    get 'List conversation messages' do
      tags 'Messages'
      security [{ bearer_auth: [] }]
      produces 'application/json'
      parameter name: :conversation_id, in: :path, type: :integer, required: true
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      response '200', 'Messages retrieved successfully' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       content: { type: :string },
                       sender_type: { type: :string, enum: ['patient', 'practitioner'] },
                       read: { type: :boolean },
                       created_at: { type: :string, format: 'date-time' }
                     }
                   }
                 },
                 pagination: {
                   type: :object,
                   properties: {
                     current_page: { type: :integer },
                     total_pages: { type: :integer },
                     total_count: { type: :integer }
                   }
                 }
               }

        before do
          @user = create(:user, :patient)
          @conversation = create(:conversation, patient_profile: @user.patient_profile)
          create_list(:message, 5, conversation: @conversation)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        let(:conversation_id) { @conversation.id }
        run_test!
      end

      response '404', 'Conversation not found' do
        before do
          @user = create(:user, :patient)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        let(:conversation_id) { 99999 }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:conversation_id) { 1 }
        run_test!
      end
    end

    post 'Create message' do
      tags 'Messages'
      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :conversation_id, in: :path, type: :integer, required: true
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          message: {
            type: :object,
            properties: {
              content: { type: :string, minLength: 1 }
            },
            required: ['content']
          }
        }
      }

      response '201', 'Message created successfully' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     content: { type: :string },
                     sender_type: { type: :string },
                     created_at: { type: :string, format: 'date-time' }
                   }
                 }
               }

        before do
          @user = create(:user, :patient)
          @conversation = create(:conversation, patient_profile: @user.patient_profile)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        let(:conversation_id) { @conversation.id }
        let(:body) do
          {
            message: {
              content: 'This is my message'
            }
          }
        end
        run_test!
      end

      response '422', 'Validation error' do
        before do
          @user = create(:user, :patient)
          @conversation = create(:conversation, patient_profile: @user.patient_profile)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        let(:conversation_id) { @conversation.id }
        let(:body) do
          {
            message: {
              content: ''
            }
          }
        end
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:conversation_id) { 1 }
        let(:body) do
          {
            message: {
              content: 'Hello'
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/conversations/{conversation_id}/messages/mark_as_read' do
    patch 'Mark messages as read' do
      tags 'Messages'
      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :conversation_id, in: :path, type: :integer, required: true
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          message_ids: {
            type: :array,
            items: { type: :integer }
          }
        }
      }

      response '200', 'Messages marked as read' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: { type: :integer }
                 },
                 message: { type: :string }
               }

        before do
          @user = create(:user, :patient)
          @conversation = create(:conversation, patient_profile: @user.patient_profile)
          @message1 = create(:message, conversation: @conversation)
          @message2 = create(:message, conversation: @conversation)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        let(:conversation_id) { @conversation.id }
        let(:body) do
          {
            message_ids: [@message1.id, @message2.id]
          }
        end
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:conversation_id) { 1 }
        let(:body) { { message_ids: [1, 2] } }
        run_test!
      end
    end
  end
end