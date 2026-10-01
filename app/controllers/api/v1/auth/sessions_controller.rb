class Api::V1::Auth::SessionsController < Devise::SessionsController
  respond_to :json

  def create
    super do |resource|
      if resource.persisted?
        return render json: {
          data: UserSerializer.new(resource).as_json,
          message: 'Login successful'
        }, status: :ok
      end
    end
  end

  def destroy
    if current_user
      super do |resource|
        return render json: {
          message: 'Logout successful'
        }, status: :ok
      end

    else
      render json: { error: 'No user loggedin' }, status: :unauthorized
    end
  end

  private

  def respond_with(resource, _opts = {})
    render json: {
      data: UserSerializer.new(resource).as_json,
      message: 'Login successful'
    }, status: :ok
  end
end