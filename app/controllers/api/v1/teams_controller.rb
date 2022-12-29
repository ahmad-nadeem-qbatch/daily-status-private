class Api::V1::TeamsController < ApplicationController
  include Invitations
  include Teams
  before_action :authenticate_user!

  # /api/v1/teams GET
  def index
    teams = if current_user.has_role? :admin
              Team.all
            else
              current_user.teams
            end
    team_ids = teams.pluck('id')
    team_managers_ids = Team.where(id: team_ids).joins(:users).where('user_teams.manager': true).pluck('user_teams.user_id')
    response = []
    teams.zip(team_managers_ids).each do |team, team_manager_id|
      team_manager_id = Invite.where(team_id: team[:id], manager: true).pluck(:user_id)[0] if team_manager_id.nil?
      if team.status == 'active'
        team_manager = User.find_by(id: team_manager_id)
        role = (current_user.has_role? :admin) || (current_user.has_role? :manager, team)
        build_all_teams_response(response, team, team_manager, role)
      end
    end
    render json: { data: { teams: response } }, status: 200
  end

  # /api/v1/stats GET
  def stats
    total_teams = Team.where(status: 'active').count
    total_members = User.where.not(invitation_accepted_at: nil).count
    total_team_managers = User.joins(:teams).where('user_teams.manager = true').count
    stats = build_stats_response(total_teams, total_team_managers, total_members)
    render json: { data: { stats: stats } }, status: 200
  end

  # /api/v1/teams/:id GET
  def team_info
    team = Team.find_by(id: params[:id])
    return send_json_response(' Invalid Team id', :unprocessable_entity) if team.nil?

    authorize team
    team_manager = Team.joins(:users).where(id: params[:id]).where('user_teams.manager = true').pluck('user_teams.user_id')
    info = build_team_info_response(team, team_manager[0])
    render json: { data: { team: info } }, status: 200 if info
  end

  # /api/v1/teams/:id/members GET
  def team_members
    team = Team.includes(:users).find_by(id: params[:id])
    return send_json_response(' Invalid Team id', :unprocessable_entity) if team.nil?

    authorize team
    response = []
    team.users.each { |user| build_team_members_response(response, user) }
    render json: { data: { team_members: response } }, status: 200
  end

  # /api/v1/teams POST
  def create
    @team = Team.new(team_params)
    @team['creation_date'] = DateTime.now
    @team['status'] = 'active'
    authorize @team
    @team.save
    if @team.persisted?
      send_json_response('Team has been created!', 200)
    else
      send_json_response("Failed to create Team. #{@team.errors.full_messages.to_sentence}", 400)
    end
  end

  # /api/v1/teams/:id PATCH
  def update
    team = Team.find_by(id: params[:id])
    return send_json_response('Could not find any team', :unprocessable_entity) if team.nil?

    authorize team
    send_invite_to_manager(team) if team_params[:manager]
    team.update_column(:name, team_params[:name]) if team_params[:name]
    team.update_column(:status, team_params[:status]) if team_params[:status]
    add_members_when_manager_invitation_accepted(team_params[:team_members], team) if team_params[:team_members]
    send_json_response('Team Edited Successfully', 200)
  end

  # /api/v1/:team_id/remove_member/:user_id PATCH
  def remove_member
    team = Team.find_by(id: params[:team_id])
    authorize team
    user = User.includes(:teams).find_by(id: params[:user_id])
    if user.teams.include?(team)
      user.teams.delete(params[:team_id])
      send_json_response('Team Member removed', 200)
    else
      send_json_response('This member does not belong to this team', :unprocessable_entity)
    end
  end

  private

  def update_manager(team)
    previous_manager_invite = Invite.find_by(team_id: team[:id], manager: true)
    previous_manager_invite&.destroy!
    send_invite_to_manager(team_params[:manager], team)
    find_remove_old_manager(team)
    UserTeam.find_by(team_id: team[:id], manager: true).destroy!
  end

  def find_remove_old_manager(team)
    old_manager = User.joins(:teams).where("user_teams.team_id= #{params[:id]}").where('manager = true')
    old_manager[0].remove_role :manager, team
  end

  def team_params
    params.require(:team).permit(:name, :status, :manager, :team_members => [])
  end
end
