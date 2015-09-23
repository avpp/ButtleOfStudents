class Battle < ActiveRecord::Base
  store :options, accessors: [:name, :config], coder: JSON
  belongs_to :owner, :class_name=>"User", :foreign_key=>"user_id"

  has_many :student_battles
  has_many :students, :class_name=> "User", :through => :student_battles
  has_many :teams
  has_many :tasks

  before_destroy :del
  def del
    self.student_battles.destroy_all
    self.teams.destroy_all
    self.tasks.destroy_all
  end
end
