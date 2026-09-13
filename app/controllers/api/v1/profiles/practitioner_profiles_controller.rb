class Api::V1::Profiles::PractitionerProfilesController < ApplicationController
  before_action :authenticat_user!

  def update
    profile = current_user.practitioner_profile
    profile.assign_attribute(practitioner_profile_params)

    if profile.save(context: :profile_completion)
      render json: {
            status: { code: 200, message: "Profile complété avec succès." },
            data: PractitionerProfileSerializer.render(profile)
          }, status: :ok
    else
          render json: {
            errors: profile.errors.full_messages
          }, status: :unprocessable_entity
    end
  end

  private

  def practitioner_profile_params
  params.require(:practitioner_profile).permit(%i[bio consultation_price_cents first_name last_name rpps_number sector])
  end

  def validate_context
    {}
  end
end
