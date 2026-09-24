require 'rails_helper'

RSpec.describe 'Api::V1::Conversations', type: :request do
  let(:appointment) { create(:appointment) }
  let(:patient_user) { appointment.patient_profile.user }
  let(:practitioner_user) { appointment.practitioner_profile.user }

  describe 'GET /api/v1/conversations' do
    it 'returns conversations for the current patient user' do
      conversation = create(
        :conversation,
        patient_profile: patient_user,
        practitioner_profile: practitioner_user
      )

      get '/api/v1/conversations', headers: auth_header(patient_user)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['data'].map { |c| c['id'] }).to include(conversation.id)
    end
  end
end
