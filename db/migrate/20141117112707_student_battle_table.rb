class StudentBattleTable < ActiveRecord::Migration
  def change
    create_table :student_battles do |t|
      t.belongs_to :user
      t.belongs_to :battle
      t.belongs_to :team

      t.timestamps
    end
  end
end
