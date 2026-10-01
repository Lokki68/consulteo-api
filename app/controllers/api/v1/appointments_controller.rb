module Api
  module V1
    class AppointmentsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_appointment, only: %i[show cancel reschedule payment_status status]

      def index
        appointments =current_user_appointments
        appointments = appointments.where(status: params[:status]) if params[:status].present?
        appointments = appointments.where("scheduled_at >= ?", params[:from]) if params[:from].present?
        appointments = appointments.where("scheduled_at >= ?", params[:to]) if params[:to].present?

        paginated = appointments.order(scheduled_at: :desc)
                                .page(params[:page])
                                .per(params[:per_page] || 20)

        render json: {
          data: AppointmentSerializer.new(paginated).as_json,
          pagination: {
            current_page: paginated.current_page,
            total_pages: paginated.total_pages,
            total_count: paginated.total_count
          }
        }
      end

      def show
        authorize_access!
        render json: {
          data: AppointmentSerializer.new(@appointment).as_json
        }
      end

      def create
        appointment = Appointment.new(appointment_params)

        if appointment.save
          render json: {
            data: AppointmentSerializer.new(appointment).as_json,
            message: 'Appointment created successfully!'
          },status: :created
        else
          render json: {
            errors: appointment.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def reschedule
        authorize_access!

        if @appointment.update(appointment_params.slice(:scheduled_at))
          render json: {
            data: AppointmentSerializer.new(@appointment).as_json,
            message: 'Appointment rescheduled successfully.'
          }
        else
          render json: {
            errors: @appointment.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def cancel
        authorize_access!

        if @appointment.update(status: :cancelled)
          render json: {
            data: AppointmentSerializer.new(@appointment).as_json,
            message: 'Appointment cancelled successfully.'
          }
        else
          render json: {
            errors: @appointment.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def payment_status
        authorize_access!

        if @appointment.update(payment_status: params[:payment_status])
          render json: {
            data: {
              id: @appointment.id,
              payment_status: @appointment.payment_status,
              amount_cents: @appointment.price_cents,
              payment_method: @appointment.payment_method,
              paid_at: @appointment.paid_at
            },
            message: 'Appointment paid successfully.'
          }
        else
          render json: {
            errors: @appointment.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def status
        authorize_access!

        if @appointment.update(status: params[:status])
        render json: {
          data: {
            id: @appointment.id,
            status: @appointment.status,
            scheduled_at: @appointment.scheduled_at,
          },
          message: "Status updated successfully!"
        }
        else
          render json: {
            errors: @appointment.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def set_appointment
        @appointment = Appointment.find(params[:id])
      end

      def current_user_appointments
        if current_user.patient_profile
          Appointment.where(patient_profile: current_user.patient_profile)
        elsif current_user.practitioner_profile
          Appointment.where(practitioner_profile: current_user.practitioner_profile)
        else
          Appointment.none
        end
      end

      def authorize_access!
        is_patient = @appointment.patient_profile == current_user.patient_profile
        is_practitioner = @appointment.practitioner_profile == current_user.practitioner_profile

        head :forbidden unless is_patient || is_practitioner
      end

      def authorize_practitioner_access!
        head :forbidden unless @appointment.practitioner_profile == current_user.practitioner_profile
      end

      def appointment_params
        params.require(:appointment).permit(
          :practitioner_profile_id,
          :scheduled_at,
          :duration,
          :consultation_type,
          :notes
        )
      end
    end
  end
end