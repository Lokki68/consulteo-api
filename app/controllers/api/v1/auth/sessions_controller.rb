class Api::V1::Auth::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    render json: {
      status: { code: 200, message: 'Connecté avec succès.' },
      data: UserSerializer.render(resource)
    }, status: :ok
  end

  def respond_to_on_destroy
    if current_user
      render json: { status: 200, message: 'Déconnecté avec succès.' }, status: :ok
    else
      render json: { status: 401, message: 'Aucun utilisateur connecté' }, status: :unauthorized
    end
  end
end