# spec/integration/api/v1/profiles_spec.rb
require 'swagger_helper'

RSpec.describe 'Profiles API', type: :request do
  path '/api/v1/profiles/patient_profiles' do
    get 'Get patient profile' do
      tags 'Profiles'
      security [{ bearer_auth: [] }]
      produces 'application/json'

      response '200', 'Patient profile retrieved successfully' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     first_name: { type: :string },
                     last_name: { type: :string },
                     date_of_birth: { type: :string, format: 'date' },
                     phone_number: { type: :string },
                     medical_history: { type: :string },
                     allergies: { type: :string }
                   }
                 }
               }

        before do
          @user = create(:user, :patient)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        run_test!
      end

      response '404', 'Profile not found' do
        before do
          @user = create(:user, :practitioner)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        run_test!
      end

      response '401', 'Unauthorized' do
        run_test!
      end
    end

    patch 'Update patient profile' do
      tags 'Profiles'
      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          patient_profile: {
            type: :object,
            properties: {
              first_name: { type: :string },
              last_name: { type: :string },
              date_of_birth: { type: :string, format: 'date' },
              phone_number: { type: :string },
              medical_history: { type: :string },
              allergies: { type: :string }
            }
          }
        }
      }

      response '200', 'Profile updated successfully' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     first_name: { type: :string },
                     last_name: { type: :string }
                   }
                 },
                 message: { type: :string }
               }

        before do
          @user = create(:user, :patient)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        let(:body) do
          {
            patient_profile: {
              first_name: 'John',
              last_name: 'Doe',
              phone_number: '+33612345678'
            }
          }
        end
        run_test!
      end

      response '422', 'Validation error' do
        before do
          @user = create(:user, :patient)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        let(:body) do
          {
            patient_profile: {
              first_name: ''
            }
          }
        end
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:body) do
          {
            patient_profile: {
              first_name: 'John'
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/profiles/practitioner_profiles' do
    get 'Get practitioner profile' do
      tags 'Profiles'
      security [{ bearer_auth: [] }]
      produces 'application/json'

      response '200', 'Practitioner profile retrieved successfully' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     first_name: { type: :string },
                     last_name: { type: :string },
                     specialization: { type: :string },
                     license_number: { type: :string },
                     experience_years: { type: :integer },
                     consultation_fee: { type: :number },
                     bio: { type: :string }
                   }
                 }
               }

        before do
          @user = create(:user, :practitioner)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        run_test!
      end

      response '404', 'Profile not found' do
        before do
          @user = create(:user, :patient)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        run_test!
      end

      response '401', 'Unauthorized' do
        run_test!
      end
    end

    patch 'Update practitioner profile' do
      tags 'Profiles'
      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          practitioner_profile: {
            type: :object,
            properties: {
              first_name: { type: :string },
              last_name: { type: :string },
              specialization: { type: :string },
              experience_years: { type: :integer },
              consultation_fee: { type: :number },
              bio: { type: :string }
            }
          }
        }
      }

      response '200', 'Profile updated successfully' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     first_name: { type: :string },
                     last_name: { type: :string },
                     specialization: { type: :string }
                   }
                 },
                 message: { type: :string }
               }

        before do
          @user = create(:user, :practitioner)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        let(:body) do
          {
            practitioner_profile: {
              first_name: 'Dr',
              last_name: 'Smith',
              specialization: 'Cardiologist',
              consultation_fee: 150.0
            }
          }
        end
        run_test!
      end

      response '422', 'Validation error' do
        before do
          @user = create(:user, :practitioner)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        let(:body) do
          {
            practitioner_profile: {
              first_name: ''
            }
          }
        end
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:body) do
          {
            practitioner_profile: {
              first_name: 'Dr'
            }
          }
        end
        run_test!
      end
    end
  end
end