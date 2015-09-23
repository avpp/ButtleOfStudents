class TasksController < ApplicationController

  access_control do
    allow :student, :to=>[:task, :tasks_list, :answer]
  end

  def answer
    @task = Task.find(params[:id])
    sb = current_user.student_battles.where(:battle_id=>@task.battle.id).first
    if sb.status!="qualification" and not @task.answers.where(:user_id=>sb.team.students.map{|s|s.id}).empty?
      render json:{:success=>false, :error=>"Вы не можете дать ответ на этот вопрос, т.к. кто-то из Вашей команды уже ответил на этот вопрос!"}
      return
    elsif sb.status == "qualification"
      if @task.student != current_user
        render json:{:success=>false, :error=>"Вы не можете дать ответ на этот вопрос, т.к. он предназначен для другого участника!"}
        return
      elsif not @task.answers.empty?
        render json:{:success=>true, :error=>"Вы уже дали правильный ответ на этот вопрос."}
        return
      end
    end
    ans = Answer.new
    ans.student = current_user
    ans.task = @task
    ans.answers = params[:answer]
    result = ans.check_answer
    ans.save if result
    tasks = current_user.tasks.where(:battle_id=>@task.battle.id)
    not_end_q = false    

    if sb.status == "qualification"
      tasks.each do |t|
        break if not_end_q = t.answers.where(:user_id=>current_user.id).empty?
      end
      if not not_end_q
        sb.status = "teamChoose"
        sb.save
      end
    end
    current_user.clear_score(@task.battle)
    render json: {:success=>result, :end_qualify=>(not not_end_q), :id=>@task.id}
  end

  def tasks_list
    battle = Battle.find(params[:battle_id])
    team = current_user.teams.where(:battle_id=>battle.id).first
    if not battle.end_time.nil? or team.nil?
      render json: false
      return
    end
    done = []
    team.students.each do |s|
      s.answered_tasks.each do |t|
        done << t.id
      end
    end
    tasks = tasks_not_done = battle.tasks.where(:user_id=>nil).order(:team_id).where.not(:id=>done)
    battle.teams.each do |t|
      if t.id != team.id and t.students.size < 2
        tasks = tasks.where.not(:team_id=>t.id)
      end
    end

    if team.students.size < 2
      tasks = tasks.where(:team_id=>team.id)
    end
    
    answer = {}
    tasks.all.each do |t|
      task = {:id=>t.id}
      task[:score] = t.get_score(current_user)
      task[:team_score] = (task[:score] * current_user.get_team_coef_for_battle(t.battle)).round(2)
      task[:solvers] = t.get_solver_list
      answer[t.id] = task
    end
    tasks_not_done.where(:team_id=>nil).each do |t|
      task = {:id=>t.id.to_s}
      task[:score] = t.get_score(current_user)
      task[:team_score] = (task[:score] * current_user.get_team_coef_for_battle(t.battle)).round(2)
      task[:solvers] = t.get_solver_list
      answer[t.id.to_s] = task
    end
    render json: answer
  end

  def task
    t = Task.find(params[:id])
    score = t.get_score(current_user)
    render json: {:id=>t.id, "team"=>{"name"=>t.team.nil? ? "Общее" : t.team.name, "color"=>t.team.nil? ? "#cccccc" : t.team.color}, "html"=>t.html, :score=>score, :team_score=>(score * current_user.get_team_coef_for_battle(t.battle)).round(2), :solvers=>t.get_solver_list, :level=>t.task_type.config["levels"][t.level]["name"]}
  end
end
