class Task < ActiveRecord::Base
  belongs_to :battle
  belongs_to :student, :class_name=>"User", :foreign_key=>"user_id"
  belongs_to :team
  belongs_to :task_type
  has_many :answers

  store :options, accessors: [:html, :level, :vars], coder: JSON

  before_destroy :del
  def del
    self.answers.destroy_all
  end

  def get_score(student)
    s = self.task_type.config["levels"][self.level]["score"].to_i
    k = self.team.nil? ? 1.2 : (self.team == student.student_battles.where(:battle_id=>self.team.battle).first.team or self.student==student) ? 1 : 0.8
    check_time = self.answers.where(:user_id => student.id).first
    if check_time.nil?
      check_time = Time.now
    else
      check_time = check_time.created_at
    end
    o = self.answers.where("created_at < ?", check_time).size + 1
    return s*k/o
  end

  def get_solver_list
    solvers = []
    self.answers.each do |a|
      solve_stud_team = a.student.student_battles.where(:battle=>a.task.battle).first.team
      solvers << {:name=>a.student.fio, :color=> (solve_stud_team.nil?) ? "#dddddd" : solve_stud_team.color}
    end
    return solvers
  end
end
