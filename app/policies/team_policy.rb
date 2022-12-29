class TeamPolicy < ApplicationPolicy
  def create?
    user.has_role? :admin
  end

  def add_members?
    (user.has_role? :manager, @record) || (user.has_role? :admin)
  end

  def update?
    (user.has_role? :manager, @record) || (user.has_role? :admin)
  end

  def remove_member?
    (user.has_role? :manager, @record) || (user.has_role? :admin)
  end

  def team_info?
    curr_user_teams = @user.teams
    curr_user_teams.include?(@record) || (user.has_role? :admin)
  end

  def team_members?
    curr_user_teams = @user.teams
    curr_user_teams.include?(@record) || (user.has_role? :admin)
  end
end
