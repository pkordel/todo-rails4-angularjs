class Api::SessionsController < Devise::SessionsController
  before_action :authenticate_user_from_token!
  before_action :warden_authenticate

  def create
    sign_in(resource_name, resource)
    resource.reset_authentication_token!
    render json: {auth_token: resource.authentication_token}
  end

  def destroy
    sign_out(resource_name)
    resource.clear_authentication_token!
    render nothing: true
  end

  private

  def warden_authenticate
    self.resource = warden.authenticate!(auth_options)
  end

  def authenticate_user_from_token!
    auth_token = params[:auth_token].presence
    user       = auth_token && User.find_by_authentication_token(auth_token)

    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && Devise.secure_compare(user.authentication_token, auth_token)
      sign_in user, store: false
    end
  end
end
