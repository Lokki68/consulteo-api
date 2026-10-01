class Api::V1::Profiles::PractitionerProfilesController < ApplicationController
  before_action :authenticat_user!

  def show
    profile = current_user.practitioner_profile

    render json: {
      data: PractitionerProfileSerializer.new(profile).as_json
    }
  rescue ActiveRecord::RecordNotFound
    render json: {
      error: 'Practitioner Profile not found'
    }, status: :not_found
  end
  def update
    profile = current_user.practitioner_profile

    if profile.update(practitioner_profile_params)
      render json: {
        data: PractitionerProfileSerializer.new(profile),
        message: 'Practitioner Profile updated'
      }
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
end
