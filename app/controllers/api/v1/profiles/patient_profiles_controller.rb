
class Api::V1::Profiles::PatientProfilesController < ApplicationController
  before_action :authenticat_user!

  def update
    profile = current_user.patient_profile
    profile.assign_attributes(patient_profile_params)

    if profile.save(context: :profile_completion)
      render json: {
        status: { code: 200, message: "Profile complété avec succès." },
        data: PatientProfileSerializer.render(profile)
      }, status: :ok
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
