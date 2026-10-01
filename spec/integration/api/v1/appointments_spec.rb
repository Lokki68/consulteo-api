# spec/integration/api/v1/appointments_spec.rb
require 'swagger_helper'

RSpec.describe 'Appointments API', type: :request do
  path '/api/v1/appointments' do
    get 'List appointments' do
      tags 'Appointments'
      security [{ bearer_auth: [] }]
      produces 'application/json'
      parameter name: :status, in: :query, type: :string, enum: ['pending', 'confirmed', 'completed', 'cancelled'], required: false
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      response '200', 'Appointments retrieved successfully' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       scheduled_at: { type: :string, format: 'date-time' },
                       status: { type: :string },
                       payment_status: { type: :string },
                       price_cents: { type: :integer }
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
          create_list(:appointment, 3, patient_profile: @user.patient_profile)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        run_test!
      end

      response '401', 'Unauthorized' do
        run_test!
      end
    end

    post 'Create appointment' do
      tags 'Appointments'
      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          appointment: {
            type: :object,
            properties: {
              practitioner_profile_id: { type: :integer },
              scheduled_at: { type: :string, format: 'date-time' },
              reason: { type: :string }
            },
            required: %w[practitioner_profile_id scheduled_at]
          }
        }
      }

      response '201', 'Appointment created successfully' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     scheduled_at: { type: :string, format: 'date-time' },
                     status: { type: :string },
                     payment_status: { type: :string }
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
            appointment: {
              practitioner_profile_id: @practitioner.practitioner_profile.id,
              scheduled_at: (Time.zone.now + 7.days).iso8601,
              reason: 'Consultation'
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
            appointment: {
              practitioner_profile_id: nil,
              scheduled_at: nil
            }
          }
        end
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:body) do
          {
            appointment: {
              practitioner_profile_id: 1,
              scheduled_at: (Time.zone.now + 7.days).iso8601
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/appointments/{id}' do
    get 'Get appointment details' do
      tags 'Appointments'
      security [{ bearer_auth: [] }]
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true

      response '200', 'Appointment retrieved successfully' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     scheduled_at: { type: :string, format: 'date-time' },
                     status: { type: :string },
                     payment_status: { type: :string },
                     reason: { type: :string }
                   }
                 }
               }

        before do
          @user = create(:user, :patient)
          @appointment = create(:appointment, patient_profile: @user.patient_profile)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        let(:id) { @appointment.id }
        run_test!
      end

      response '404', 'Appointment not found' do
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

    patch 'Cancel appointment' do
      tags 'Appointments'
      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          cancellation_reason: { type: :string }
        }
      }

      response '200', 'Appointment cancelled successfully' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     status: { type: :string },
                     cancellation_reason: { type: :string }
                   }
                 },
                 message: { type: :string }
               }

        before do
          @user = create(:user, :patient)
          @appointment = create(:appointment, patient_profile: @user.patient_profile, status: 'pending')
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        let(:id) { @appointment.id }
        let(:body) { { cancellation_reason: 'I cannot attend' } }
        run_test!
      end

      response '422', 'Cannot cancel this appointment' do
        before do
          @user = create(:user, :patient)
          @appointment = create(:appointment, patient_profile: @user.patient_profile, status: 'completed')
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        let(:id) { @appointment.id }
        let(:body) { { cancellation_reason: 'Too late' } }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:id) { 1 }
        let(:body) { { cancellation_reason: 'Reason' } }
        run_test!
      end
    end
  end

  path '/api/v1/appointments/{id}/reschedule' do
    patch 'Reschedule appointment' do
      tags 'Appointments'
      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          appointment: {
            type: :object,
            properties: {
              scheduled_at: { type: :string, format: 'date-time' }
            },
            required: ['scheduled_at']
          }
        }
      }

      response '200', 'Appointment rescheduled successfully' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     scheduled_at: { type: :string, format: 'date-time' }
                   }
                 },
                 message: { type: :string }
               }

        before do
          @user = create(:user, :patient)
          @appointment = create(:appointment, patient_profile: @user.patient_profile, status: 'pending')
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        let(:id) { @appointment.id }
        let(:body) do
          {
            appointment: {
              scheduled_at: (Time.zone.now + 14.days).iso8601
            }
          }
        end
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:id) { 1 }
        let(:body) do
          {
            appointment: {
              scheduled_at: (Time.zone.now + 14.days).iso8601
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/appointments/{id}/payment_status' do
    patch 'Update appointment payment status' do
      tags 'Appointments'
      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          payment_status: { type: :string, enum: ['pending', 'paid', 'failed'] }
        },
        required: ['payment_status']
      }

      response '200', 'Payment status updated successfully' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     payment_status: { type: :string }
                   }
                 },
                 message: { type: :string }
               }

        before do
          @user = create(:user, :patient)
          @appointment = create(:appointment, patient_profile: @user.patient_profile)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        let(:id) { @appointment.id }
        let(:body) { { payment_status: 'paid' } }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:id) { 1 }
        let(:body) { { payment_status: 'paid' } }
        run_test!
      end
    end
  end

  path '/api/v1/appointments/{id}/status' do
    patch 'Update appointment status' do
      tags 'Appointments'
      security [{ bearer_auth: [] }]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          status: { type: :string, enum: ['pending', 'confirmed', 'completed', 'cancelled'] }
        },
        required: ['status']
      }

      response '200', 'Status updated successfully' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     status: { type: :string }
                   }
                 },
                 message: { type: :string }
               }

        before do
          @user = create(:user, :practitioner)
          @appointment = create(:appointment, practitioner_profile: @user.practitioner_profile)
        end

        let(:Authorization) { "Bearer #{create_jwt_token(@user)}" }
        let(:id) { @appointment.id }
        let(:body) { { status: 'confirmed' } }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:id) { 1 }
        let(:body) { { status: 'confirmed' } }
        run_test!
      end
    end
  end
end