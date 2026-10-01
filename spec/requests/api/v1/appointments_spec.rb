require 'rails_helper'

RSpec.describe "Api::V1::Appointments", type: :request do
  let(:patient_user) { create(:user, :patient) }
  let(:patient_profile) { patient_user.patient_profile }

  let(:practitioner_user) { create(:user, :practitioner) }
  let(:practitioner_profile) { practitioner_user.practitioner_profile }

  describe "GET /api/v1/appointments" do
    it 'retourne les rendez-vous du patient connecté' do
      appointment = create(:appointment, patient_profile: patient_profile)
      puts "appointment -> #{appointment.errors.full_messages}"
      create(:appointment)

      get 'api/v1/appointments', headers: auth_headers(patient_user)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).count).to eq(1)
      expect(JSON.parse(response.body).first['id']).to eq(appointment.id)
    end
  end
end