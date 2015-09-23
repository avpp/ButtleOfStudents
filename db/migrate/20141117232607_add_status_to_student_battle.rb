class AddStatusToStudentBattle < ActiveRecord::Migration
  def change
    add_column :student_battles, :status, :string
  end
end
