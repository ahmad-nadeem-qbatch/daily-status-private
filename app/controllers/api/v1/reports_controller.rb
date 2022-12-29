class Api::V1::ReportsController < ApplicationController
  before_action :authenticate_user!

  # /api/v1/reports GET
  def index
    # get reports of currently signed in user in given team
    reports = Report.where(user_id: current_user[:id], team_id: params[:team_id])
    return render json: { data: { reports: reports } }, status: 200 if reports

    send_json_response('Could find any reports!', :unprocessable_entity)
  end

  # /api/v1/reports POST
  def create
    team = Team.find_by(id: params[:report][:team_id])
    return send_json_response('Invalid Team', :unprocessable_entity) if team.nil?

    authorize(team, policy_class: ReportPolicy)
    return send_json_response('', :unprocessable_entity) unless team.users.include?(current_user)

    report = Report.new(report_params)
    report.user_id = current_user.id if report.present?
    return render json: { data: { report: report } }, status: 201 if report.save

    send_json_response('Could not create the report', :unprocessable_entity)
  end

  private

  def report_params
    params.require(:report).permit(:date, :title, :task_link, :time_spent, :time_remaining, :status, :blockers, :team_id)
  end
end
