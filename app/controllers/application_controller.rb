require "application_responder"
class ApplicationController < ActionController::API
  include Response
  self.responder = ApplicationResponder
  respond_to :html, :json

  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :no_access_message

  private

  def no_access_message
    render json: {
      data: { status: 401, message: 'You do not have access to perform the following option' }
    }, status: 401
  end
end
