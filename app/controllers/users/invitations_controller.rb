class Users::InvitationsController < Devise::InvitationsController
  include Invitations
  before_action -> { authenticate_user!(force: true) }, except: [:accept_invite, :register]
  before_action :configure_permitted_paramters
  before_action :configure_invite_params
  respond_to :json

  # /add_members POST
  def add_members
    members = params[:users][:emails]
    @team = Team.find_by(id: params[:team_id])
    return send_json_response('Invalid Team', :unprocessable_entity) if @team.nil?

    authorize @team
    team_manager = Invite.find_by(team_id: params[:team_id], manager: true)
    return send_json_response('No invite sent to Team manager', :unprocessable_entity) unless team_manager

    if team_manager.invitation_accepted_at.nil?
      add_members_when_manager_invitation_pending(members, @team)
    else
      add_members_when_manager_invitation_accepted(members, @team)
    end
    send_json_response('Team members Added', 201)
  end

  # /teams POST
  def team_invite
    team = Team.find_by(name: params[:team])
    return send_json_response('This team already exists', :unprocessable_entity) if team.present?

    team = Team.create(name: params[:team], creation_date: DateTime.now)
    manager_invite, member_invite = nil
    manager = params[:manager]
    members = params[:users]
    return send_json_response('Manager must be present', :unprocessable_entity) if manager.nil?

    manager_invite = send_invite_to_manager(manager, team)
    members.each do |member|
      member_invite = check_if_manager_accepted_invite(member, team, manager_invite)
    end
    send_json_response('Invites Sent Successfully', 201) if manager_invite && member_invite
  end

  # /accept_invite POST
  def accept_invite
    user_params = params[:users]
    user_invite = Invite.find_by(invitation_token: user_params[:invitation_token])
    return send_json_response('Invalid Invitaation token!', :unprocessable_entity) if user_invite.nil?

    if user_invite.invitation_accepted_at.nil?
      user = User.find_by(id: user_invite.user_id)
      return send_json_response('Sign Up to continue', :unprocessable_entity) if user.invitation_accepted_at.nil?

      user_invite.update(invitation_accepted_at: DateTime.now)
      team = Team.find_by(id: user_invite.team_id)
      # if the normal member is accepting as team-lead in the future
      user.teams << team unless user.teams.include?(team)
      update_user_teams(user, team) if user_invite.manager
      send_invites_to_subordinates(user_invite.team_id) if user_invite.manager
      send_json_response('Invite Accepted', 201)
    else
      send_json_response('This Invite is expired', :unprocessable_entity)
    end
  end

  # /register POST
  def register
    user_params = params[:user]
    user_invite = Invite.find_by(invitation_token: user_params[:invitation_token])
    user = User.find_by(id: user_invite.user_id)
    update_user(user, user_params) if user.invitation_accepted_at.nil?
    send_json_response('User Updated successfully!', 201)
  end

  private

  def update_user(user, user_params)
    user.first_name = user_params[:first_name] if user_params[:first_name]
    user.last_name = user_params[:last_name] if user_params[:last_name]
    user.password = user_params[:password]
    user.invitation_accepted_at = DateTime.now
    user.save!
  end

  def update_user_teams(user, team)
    UserTeam.find_by(user_id: user[:id], team_id: team[:id]).update(manager: true)
  end

  def update_team(user, team)
    team.manager << user
    team.save!
  end

  def user_params
    params.require(:users).permit(:password, :first_name, :last_name, :invitation_token)
  end

  def send_invites_to_subordinates(team_id)
    subordinates = Invite.where(team_id: team_id).where(manager: false).where(invitation_sent_at: nil).select(:user_id)
    return if subordinates.empty?

    users = User.where(id: subordinates)
    users.each do |user|
      user.invite!
      Invite.find_by(user_id: user.id, team_id: team_id).update(invitation_token: user.raw_invitation_token, invitation_sent_at: user.invitation_sent_at)
    end
  end

  def check_if_manager_accepted_invite(team_member, team, manager_invite)
    if manager_invite.invitation_accepted_at.nil?
      add_team_member_to_user_table(team_member, team)
    end
  end

  def add_team_member_to_user_table(team_member, team)
    user = User.find_by(email: team_member)
    if user.nil?
      user = User.invite!(email: team_member, skip_invitation: true)
    else
      user.skip_invitation = true
      user.invite!
    end
    Invite.create(user: user, team: team, manager: false)
  end

  def configure_invite_params
    devise_parameter_sanitizer.permit(:invite, keys: [:email, :role])
  end

  def configure_permitted_paramters
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:first_name, :last_name, :invitation_token, :password])
  end
end
