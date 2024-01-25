class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?
  skip_before_action :verify_authenticity_token
  respond_to :json

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name role])
  end

  def after_sign_up_path_for(_resource)
    '/'
  end

  def after_update_path_for(_resource)
    '/'
  end

  def respond_with(resource, _options = {})
    if resource.persisted?
      token = JWT.encode(resource.jwt_payload, Rails.application.credentials.fetch(:secret_key_base))

      render json: {
        status: { code: 200, message: 'Signed up sucessfully.', data: resource, token: token }
      }, status: :ok
    else
      render json: {
        status: { message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}" }
      }, status: :unprocessable_entity
    end
  end
end
