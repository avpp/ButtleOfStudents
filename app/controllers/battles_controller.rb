class BattlesController < ApplicationController

  def is_my?
    return current_user == Battle.find(params[:id]||params[:battle_id]).owner
  end

  access_control do
    allow :admin, :to=>[:index, :show, :manage, :stop]
    allow :teacher, :to=>[:new, :create, :index]
    allow :teacher, :to=>[:manage, :stop, :destroy], :if=>:is_my?
    allow :student, :to=>[:assign]
    allow all, :to=>[:show, :team_raiting, :person_raiting]
  end

  def index
  end

  def new
    @battle = Battle.new
  end
  def parse(v)
    return [] if v.nil?
    s = v[:type].size
    ans = []
    s.times do |i|
      ans << {:type => v[:type][i], :count => v[:count][i], :level => v[:level][i]}
    end
    return ans
  end
  def create
    @battle = Battle.new(params.require(:battle).permit(:name, :only_my_student))
    @battle.config = {}
    @battle.config["q_conf"] = parse(params[:task_q_conf]);
    @battle.config["t_conf"] = parse(params[:task_t_conf]);
    @battle.config["u_conf"] = parse(params[:task_u_conf]);
    @battle.start_time = Time.now
    @battle.owner = current_user
    @battle.save
    if not @battle.config["u_conf"].empty?
      conf = @battle.config["u_conf"]
      conf.each do |c|
        c["count"].to_i.times do
          TaskType.find(c["type"]).generate_task_for(nil, @battle, c["level"])
        end
      end
    end
    redirect_to battles_path
  end
  def destroy
    @battle = Battle.find(params[:id])
    @battle.destroy
    redirect_to battles_path
  end

  def stop
    @battle = Battle.find(params[:battle_id])
    @battle.end_time = Time.now
    @battle.save
    redirect_to battles_path
  end

  def assign
    @battle = Battle.find(params[:battle_id])
    @battle.students<<current_user
    @battle.save
    sb = current_user.student_battles.where(:battle_id=>@battle.id).first
    sb.status = "qualification"
    sb.save
    if not @battle.config["q_conf"].empty?
      conf = @battle.config["q_conf"]
      conf.each do |c|
        c["count"].to_i.times do 
          TaskType.find(c["type"]).generate_task_for(current_user, @battle, c["level"])
        end
      end
    end
    redirect_to :root
  end

  def show
    @battle = Battle.find(params[:id])
    
  end

  def manage
    @battle = Battle.find(params[:battle_id])
  end

  def person_raiting
    answer = []
    @battle = Battle.find(params[:battle_id])
    @battle.students.each do |s|
      ans = {}
      team = s.student_battles.where(:battle_id=>@battle).first.team
      ans["color"] = team.nil? ? "#DDDDDD" : team.color
      ans["name"] = s.fio
      ans["score"] = s.score(@battle).round(2)
      ans["avg_score"] = (s.answers.size == 0) ? 0 : (ans["score"]/s.answers.size).round(3);
      answer << ans
    end
    render json: {"raitings"=>answer, "battle_stop"=>(not @battle.end_time.nil?)}
  end

  def team_raiting
    answer = []
    @battle = Battle.find(params[:battle_id])
    @battle.teams.each do |t|
      ans = {}
      ans["color"] = t.color
      ans["name"] = t.name
      ans["score"] = t.score.round(2)
      answer << ans
    end
    render json: {"raitings"=>answer, "battle_stop"=>(not @battle.end_time.nil?)}
  end
end
