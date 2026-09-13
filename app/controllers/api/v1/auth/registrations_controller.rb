class Api::V1::Auth::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        status: { code: 200, message: 'Compte créé avec succès.' },
        data: UserSerializer.render(resource)
      }, status: :ok
    else
      render json: {
        status: { code: 422, message: 'Erreur lors de la création du compte.' },
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def sign_up_params
    params.require(:user).permit(%i(email password password_confirmation role))
  end
end