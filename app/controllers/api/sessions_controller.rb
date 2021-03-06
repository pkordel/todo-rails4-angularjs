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
    self.resource = auth_token && User.where(authentication_token: auth_token).first

    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if self.resource && Devise.secure_compare(self.resource.authentication_token, auth_token)
      sign_in self.resource, store: false
    end
  end
end
