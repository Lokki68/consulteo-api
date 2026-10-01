# spec/integration/api/v1/auth_spec.rb
require 'swagger_helper'

RSpec.describe 'Authentication API', type: :request do
  path '/api/v1/auth/sign_up' do
    post 'User registration' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email },
              password: { type: :string, minLength: 6 },
              password_confirmation: { type: :string },
              profile_type: { type: :string, enum: ['patient', 'practitioner'] }
            },
            required: %w[email password password_confirmation profile_type]
          }
        }
      }

      response '201', 'User registered successfully' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     email: { type: :string },
                     profile_type: { type: :string }
                   }
                 },
                 message: { type: :string }
               }
        let(:body) do
          {
            user: {
              email: 'newuser@example.com',
              password: 'password123',
              password_confirmation: 'password123',
              profile_type: 'patient'
            }
          }
        end
        run_test!
      end

      response '422', 'Validation errors' do
        schema type: :object,
               properties: {
                 errors: {
                   type: :array,
                   items: { type: :string }
                 }
               }
        let(:body) do
          {
            user: {
              email: 'invalid',
              password: '123',
              password_confirmation: '123',
              profile_type: 'patient'
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/auth/sign_in' do
    post 'User login' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email },
              password: { type: :string }
            },
            required: %w[email password]
          }
        }
      }

      response '200', 'Login successful' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     email: { type: :string },
                     authentication_token: { type: :string }
                   }
                 },
                 message: { type: :string }
               }

        before do
          @user = create(:user, :patient, email: 'patient@test.com', password: 'password123')
        end

        let(:body) do
          {
            user: {
              email: 'patient@test.com',
              password: 'password123'
            }
          }
        end
        run_test!
      end

      response '401', 'Invalid credentials' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }
        let(:body) do
          {
            user: {
              email: 'wrong@example.com',
              password: 'wrongpassword'
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/auth/sign_out' do
    delete 'User logout' do
      tags 'Authentication'
      security [{ bearer_auth: [] }]
      produces 'application/json'

      response '200', 'Logout successful' do
        schema type: :object,
               properties: {
                 message: { type: :string }
               }

        before do
          @user = create(:user, :patient)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        run_test!
      end

      response '401', 'Unauthorized' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }
        run_test!
      end
    end
  end
end