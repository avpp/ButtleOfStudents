class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable, :trackable, :validatable
  acts_as_authorization_subject  :association_name => :roles

  store :info, accessors: [:personal, :additional, :score_cache], coder: JSON

  has_many :battles
  has_many :student_battles
  has_many :in_battles, :through=>:student_battles, :source=>:battle
  has_many :teams, :through=>:student_battles, :source=>:team
  has_many :tasks
  has_many :answers
  has_many :answered_tasks, :through=>:answers, :source=>:task

  def fio
    return "" if self.info[:personal].nil? or self.info[:personal].empty?
    return self.info[:personal][:surname].to_s + " " + self.info[:personal][:name].to_s + " " + self.info[:personal][:patronymic].to_s
  end

  def get_team_coef_for_battle(battle)
    tat = self.student_battles.where(:battle_id=>battle).first.team_assign_time
    tcoef = StudentBattle.where(:battle_id=>battle).where("team_assign_time < ?", tat).size
    return 1 + tcoef*0.5/battle.students.size
  end

  def update_score(battle)
    result = 0
    self.answers.where(:task_id=>battle.tasks.map{|b| b.id}).each do |a|
      result += a.task.get_score(self)
    end
    self.score_cache = self.score_cache || {}
    self.score_cache[battle.id.to_s] = result
    self.save
    return result
  end

  def clear_score(battle)
    return if self.score_cache.nil?
    self.score_cache.delete(battle.id.to_s)
    self.save
  end

  def score(battle)
    return self.score_cache[battle.id.to_s] if not self.score_cache.nil? and self.score_cache.include?(battle.id.to_s)
    return update_score(battle)
  end
end
