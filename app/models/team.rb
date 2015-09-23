class Team < ActiveRecord::Base
  has_many :student_battles
  has_many :students, :class_name=> "User", :through => :student_battles
  belongs_to :battle
  has_many :tasks

  store :options, accessors: [:max_stud, :color], coder: JSON

  def score
    sz = self.students.size
    return 0 if sz == 0
    result = 0
    self.students.each do |s|
      result += s.score(self.battle)*s.get_team_coef_for_battle(self.battle)
    end
    return result/sz
  end
end
