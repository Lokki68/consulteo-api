module Api
  module V1
    class AppointmentsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_appointment, only: %i[show cancel reschedule payment_status status]

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