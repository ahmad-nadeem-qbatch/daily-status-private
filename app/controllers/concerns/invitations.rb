module Invitations
  def send_invite_to_manager(manager, team)
    user = User.find_by(email: manager)
    user ? user.invite! : user = User.invite!(email: manager) # invite if the user is already existing otherwise create the user and send invite
    user&.add_role :manager, team
    Invite.create(user: user, team: team, invitation_token: user.raw_invitation_token,
                  invitation_created_at: user.invitation_created_at, invitation_sent_at: user.invitation_sent_at,
                  manager: true)
  end

  def add_members_when_manager_invitation_accepted(members, team)
    members.each do |member|
      user = User.find_by(email: member)
      if user
        member_invite = Invite.find_by(user_id: user[:id], team_id: params[:team_id], manager: false)
        member_invite ? send_invite_and_update_token(user, member_invite) : send_new_invite(user, team)
      else
        user = User.invite!(email: member)
        Invite.create(user: user, team: team, invitation_token: user.raw_invitation_token,
                      invitation_created_at: user.invitation_created_at, invitation_sent_at: user.invitation_sent_at,
                      manager: false)
      end
    end
  end

  def add_members_when_manager_invitation_pending(members, team)
    members.each do |member|
      user = User.find_by(email: member)
      if user
        member_invite = Invite.where(user_id: user[:id]).where(team_id: params[:team_id]).where(manager: false)
        member_invite ? skip_invite_and_update_token(user, member_invite) : create_new_invite(user, team)
      else
        create_new_user_and_invite(member, team)
      end
    end
  end

  def send_invite_and_update_token(user, member_invite)
    user.invite!
    member_invite.update(invitation_token: user.raw_invitation_token, invitation_sent_at: user.invitation_sent_at)
  end


  def skip_invite_and_update_token(user, member_invite)
    user.skip_invitation = true
    user.invite!
    member_invite.update(invitation_token: user.raw_invitation_token)
  end

  def create_new_invite(user, team)
    Invite.create(user: user, team: team, invitation_token: user.raw_invitation_token,
                  invitation_created_at: user.invitation_created_at, manager: false)
  end

  def create_new_user_and_invite(member, team)
    user = User.invite!(email: member, skip_invitation: true)
    Invite.create(user: user, team: team, manager: false)
  end

  def send_new_invite(user, team)
    user.invite!
    Invite.create(user: user, team: team, invitation_token: user.raw_invitation_token,
                  invitation_created_at: user.invitation_created_at, invitation_sent_at: user.invitation_sent_at,
                  manager: false)
  end
end
