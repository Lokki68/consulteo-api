# spec/integration/api/v1/conversations_spec.rb
require 'swagger_helper'

RSpec.describe 'Conversations API', type: :request do
  path '/api/v1/conversations' do
    get 'List user conversations' do
      tags 'Conversations'
      security [{ bearer_auth: [] }]
      produces 'application/json'

      response '200', 'Conversations retrieved successfully' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       patient_profile_id: { type: :integer },
                       practitioner_profile_id: { type: :integer },
                       initiated_by: { type: :string, enum: ['patient', 'practitioner'] },
                       created_at: { type: :string, format: 'date-time' }
                     }
                   }
                 }
               }

        before do
          @user = create(:user, :patient)
          create_list(:conversation, 3, patient_profile: @user.patient_profile)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        run_test!
      end

      response '401', 'Unauthorized' do
        run_test!
      end
    end

    post 'Create conversation' do
      tags 'Conversations'
      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          conversation: {
            type: :object,
            properties: {
              practitioner_profile_id: { type: :integer },
              initial_message: { type: :string }
            },
            required: ['practitioner_profile_id']
          }
        }
      }

      response '201', 'Conversation created successfully' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     patient_profile_id: { type: :integer },
                     practitioner_profile_id: { type: :integer },
                     initiated_by: { type: :string }
                   }
                 },
                 message: { type: :string }
               }

        before do
          @user = create(:user, :patient)
          @practitioner = create(:user, :practitioner)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        let(:body) do
          {
            conversation: {
              practitioner_profile_id: @practitioner.practitioner_profile.id,
              initial_message: 'Hello, I need help'
            }
          }
        end
        run_test!
      end

      response '403', 'Only patients can create conversations' do
        before do
          @user = create(:user, :practitioner)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        let(:body) do
          {
            conversation: {
              practitioner_profile_id: 1
            }
          }
        end
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:body) do
          {
            conversation: {
              practitioner_profile_id: 1
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/conversations/{id}' do
    get 'Get conversation details' do
      tags 'Conversations'
      security [{ bearer_auth: [] }]
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true

      response '200', 'Conversation retrieved successfully' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     patient_profile_id: { type: :integer },
                     practitioner_profile_id: { type: :integer },
                     initiated_by: { type: :string },
                     created_at: { type: :string, format: 'date-time' }
                   }
                 }
               }

        before do
          @user = create(:user, :patient)
          @conversation = create(:conversation, patient_profile: @user.patient_profile)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        let(:id) { @conversation.id }
        run_test!
      end

      response '404', 'Conversation not found' do
        before do
          @user = create(:user, :patient)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        let(:id) { 99999 }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:id) { 1 }
        run_test!
      end
    end
  end
end