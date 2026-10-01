# spec/integration/api/v1/practitioners_spec.rb
require 'swagger_helper'

RSpec.describe 'Practitioners API', type: :request do
  path '/api/v1/practitioners' do
    get 'List all practitioners' do
      tags 'Practitioners'
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      response '200', 'Practitioners retrieved successfully' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       first_name: { type: :string },
                       last_name: { type: :string },
                       specialization: { type: :string },
                       bio: { type: :string },
                       consultation_fee: { type: :number }
                     }
                   }
                 }
               }

        before do
          create_list(:user, 3, :practitioner)
        end

        run_test!
      end
    end
  end

  path '/api/v1/practitioners/{id}' do
    get 'Get practitioner details' do
      tags 'Practitioners'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true

      response '200', 'Practitioner retrieved successfully' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     first_name: { type: :string },
                     last_name: { type: :string },
                     specialization: { type: :string },
                     bio: { type: :string },
                     experience_years: { type: :integer },
                     consultation_fee: { type: :number }
                   }
                 }
               }

        before do
          @practitioner = create(:user, :practitioner)
        end

        let(:id) { @practitioner.practitioner_profile.id }
        run_test!
      end

      response '404', 'Practitioner not found' do
        let(:id) { 99999 }
        run_test!
      end
    end
  end

  path '/api/v1/practitioners/{id}/available_slots' do
    get 'Get practitioner available slots' do
      tags 'Practitioners'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true
      parameter name: :date_from, in: :query, type: :string, format: 'date', required: false
      parameter name: :date_to, in: :query, type: :string, format: 'date', required: false

      response '200', 'Available slots retrieved successfully' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       date: { type: :string, format: 'date' },
                       slots: {
                         type: :array,
                         items: {
                           type: :object,
                           properties: {
                             start_time: { type: :string, format: 'time' },
                             end_time: { type: :string, format: 'time' },
                             available: { type: :boolean }
                           }
                         }
                       }
                     }
                   }
                 }
               }

        before do
          @practitioner = create(:user, :practitioner)
        end

        let(:id) { @practitioner.practitioner_profile.id }
        run_test!
      end

      response '404', 'Practitioner not found' do
        let(:id) { 99999 }
        run_test!
      end
    end
  end
end