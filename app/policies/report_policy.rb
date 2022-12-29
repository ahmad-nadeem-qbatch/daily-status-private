class ReportPolicy < ApplicationPolicy
  def create?
    puts @record.users.include?(@user)
    @record.users.include?(@user)
  end
end
