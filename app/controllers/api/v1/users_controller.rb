class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!

  # /api/v1/users GET
  def index
    # return all the users that have registered after accepting the invite
    users = User.select(:id, :first_name, :last_name, :email).where.not(invitation_accepted_at: nil)
    return render json: { data: { users: users } }, status: 200 if users

    send_json_response('Error fetching users', :unprocessable_entity)
  end

  # /api/v1/upload POST
  def upload_picture
    current_user.profile_picture.purge if current_user.profile_picture.attached?
    current_user.profile_picture.attach(params[:image])
    current_user.update_column(:image, url_for(current_user.profile_picture))
    if current_user.errors.any?
      send_json_response("#{current_user.errors.full_messages}", :unprocessable_entity)
    else
      send_json_response('Picture uploaded successfully', 201)
    end
  end
end
