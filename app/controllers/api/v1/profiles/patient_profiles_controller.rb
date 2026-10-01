
class Api::V1::Profiles::PatientProfilesController < ApplicationController
  before_action :authenticat_user!


  def show
    profile = current_user.patient_profile

    render json: {
      data: PatientProfileSerializer.new(profile).as_json
    }

  rescue ActiveRecord::RecordNotFound
    render json: {
      error: 'Profile not found'
    }, status: :not_found
  end

  def update
    profile = current_user.patient_profile

    if profile.update(patient_profile_params)
      render json: {
        data: PatientProfileSerializer.new(profile).as_json,
        message: 'Profile updated successfully'
      }
    else
      render json: {
        errors: profile.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def patient_profile_params
    params.require(:patient_profile).permit(%i[first_name last_name date_of_birth phone_number address city postal_code social_security_number])
  end

  def validate_context
    {}
  end
end
