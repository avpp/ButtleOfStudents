class AddTeamAssignTimeToStudentBattle < ActiveRecord::Migration
  def change
    add_column :student_battles, :team_assign_time, :timestamp
  end
end
