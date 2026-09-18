require 'rails_helper'

RSpec.describe "GET /api/v1/practitioners/:id/availabel_slots", type: :request do
  let(:practitioner) { create(:practitioner_profile) }

  before do
    create(:availability_rule, practitioner_profile: practitioner, day_of_week: 1, start_time: "09:00", end_time: "12:00", slot_duration_minutes: 60)
  end

  context 'requête valide sans params (valeurs par défaut)' do
    it 'retourne 200 avec la structure attendue' do
      get "/api/v1/practitioners/#{practitioner.id}/available_slots"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to have_key('slots')
    end
  end

  context 'avec from_date et to_date explicites' do
    it 'retourne le créneau du bon lundi' do
      monday = Date.current.next_occurring(:monday)

      get "/api/v1/practitioners/#{practitioner.id}/available_slots", params: { from_date: monday.iso8601, to_date: monday.iso8601 }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['slots'][monday.iso8601].size).to eq(3)
    end
  end

  context 'practitioner inexistant' do
    it 'retourne 404' do
      get '/api/v1/practitioners/99999/available_slots'

      expect(response).to have_http_status(:not_found)
    end
  end

  context 'from_date invalide' do
    it 'retourne 422' do
      get "/api/v1/practitioners/#{practitioner.id}/available_slots", params: { from_date: 'not-a-date' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to match(/Format de date invalide/)
    end
  end

  context 'to_date avant from_date' do
    it 'retourne 422' do
      get "/api/v1/practitioners/#{practitioner.id}/available_slots", params: { from_date: '2026-09-12', to_date: '2026-09-09' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to match(/après from_date/)
    end
  end

  context 'plage supérieur a 60 jours' do
    it 'retourne 422' do
      get "/api/v1/practitioners/#{practitioner.id}/available_slots", params: { from_date: '2026-09-12', to_date: '2026-12-20' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to match(/60 jours/)
    end
  end

end