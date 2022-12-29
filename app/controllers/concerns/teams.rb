module Teams
  def build_all_teams_response(response_array, team, team_manager, role)
    response_array << { 'team_name' => team.name,
                        'total_members' => team.users.count,
                        'date_of_creation' => team.creation_date,
                        'team_lead_name' => "#{team_manager.first_name} #{team_manager.last_name}",
                        'status' => team.status,
                        'manager' => role }
  end

  def build_team_info_response(team, team_manager_id)
    manager = User.find_by(id: team_manager_id) unless team_manager_id.nil?
    if manager
      response_when_manager_accepted(team, manager)
    else
      response_when_manager_pending(team)
    end
  end

  def response_when_manager_accepted(team, manager)
    {
      'team_name' => team.name,
      'total_members' => team.users.count,
      'date_of_creation' => team.creation_date,
      'team_lead_name' => "#{manager.first_name} #{manager.last_name}",
      'team_lead_email' => manager.email.to_s,
      'status' => team.status
    }
  end

  def response_when_manager_pending(team)
    {
      'team_name' => team.name,
      'total_members' => team.users.count,
      'date_of_creation' => team.creation_date,
      'team_lead_name' => 'Pending Invitation',
      'team_lead_email' => 'Pending Invitation',
      'status' => team.status
    }
  end

  def build_team_members_response(response_array, team_member)
    response_array << { 'name' => "#{team_member.first_name} #{team_member.last_name}",
                        'email' => team_member.email,
                        'image' => team_member.image }
  end

  def build_stats_response(total_teams, total_team_managers, total_members)
    {
      'total teams' => total_teams,
      'total team leads' => total_team_managers,
      'total members' => total_members
    }
  end
end
