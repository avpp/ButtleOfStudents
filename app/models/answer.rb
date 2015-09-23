class Answer < ActiveRecord::Base
  belongs_to :student, :class_name=>"User", :foreign_key=>"user_id"
  belongs_to :task

  store :options, accessors: [:answers], coder: JSON

  def check_answer
    vars = self.task.vars
    check = self.task.task_type.config["answer"]
    check.gsub!(/%(\w)/) {|m| vars[$1]}
    check.gsub!(/%!(\w)/) {|m| self.answers[$1]}
    return eval(check)
  end
end
