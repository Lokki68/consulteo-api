require 'rails_helper'

RSpec.describe 'Api::V1::Conversations', type: :request do
  let(:appointment) { create(:appointment) }
  let(:patient_user) { appointment.patient_profile.user }
  let(:practitioner_user) { appointment.practitioner_profile.user }

  describe 'GET /api/v1/conversations' do
    it 'returns conversations for the current patient user' do
      conversation = create(
        :conversation,
        patient_profile: appointment.patient_profile,
        practitioner_profile: appointment.practitioner_profile
      )

      get '/api/v1/conversations', headers: auth_headers(patient_user)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['data'].map { |c| c['id'] }).to include(conversation.id)
    end

    it 'returns 401 without authentications' do
      get '/api/v1/conversations'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/conversations/:id' do
    it 'returns the conversation with its messages' do
      conversation = create(
        :conversation,
        patient_profile: appointment.patient_profile,
        practitioner_profile: appointment.practitioner_profile
      )
      message = create(:message, conversation: conversation, sender: patient_user)

      get "/api/v1/conversations/#{conversation.id}", headers: auth_headers(patient_user)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['data']['id']).to eq(conversation.id)
      expect(body['data']['messages'].map { |m| m['id'] }).to include(message.id)
    end

    it 'returns 404 if user is not part of the conversation' do
      conversation = create(
        :conversation,
        patient_profile: appointment.patient_profile,
        practitioner_profile: appointment.practitioner_profile
      )

      other_patient_profile = create(:user, :patient)

      get "/api/v1/conversations/#{conversation.id}", headers: auth_headers(other_patient_profile)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/conversations' do
    it 'creates a conversation between patient and practitioner with existing appointment' do
      post '/api/v1/conversations',
           params: { practitioner_profile_id: appointment.practitioner_profile.id },
           headers: auth_headers(patient_user)

      expect(response).to have_http_status(:created)
      expect(Conversation.count).to eq(1)
    end

    context 'when initialize by a practitioner' do
      it 'is forbidden ' do
        post '/api/v1/conversations',
             params: {practitioner_profile_id: appointment.practitioner_profile.id},
             headers: auth_headers(practitioner_user)

        expect(response).to have_http_status(:forbidden)
        expect(Conversation.count).to eq(0)
      end
    end

    it 'returns 422 if no appointment exists between patient and practitioner' do
      other_practitioner = create(:practitioner_profile)

      post '/api/v1/conversations',
           params: { practitioner_profile_id: other_practitioner.id },
           headers: auth_headers(patient_user)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns existing conversation if already created' do
      conversation = create(:conversation,
                            patient_profile: appointment.patient_profile,
                            practitioner_profile: appointment.practitioner_profile
                            )

      post '/api/v1/conversations',
           params: { practitioner_profile_id: appointment.practitioner_profile.id },
           headers: auth_headers(patient_user)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['data']['id']).to eq(conversation.id)
      expect(Conversation.count).to eq(1)
    end
  end
end
