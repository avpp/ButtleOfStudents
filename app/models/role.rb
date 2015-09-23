class Role < ActiveRecord::Base
  acts_as_authorization_role

  def self.list
    ans = {
      :admin   => {:name=>"Администратор"},
      :task_manager => {:name=>"менеджер по заданиям"},
      :teacher => {:name=>"Преподаватель"},
      :student => {:name=>"Студент"}
    }
    return ans
  end
end
