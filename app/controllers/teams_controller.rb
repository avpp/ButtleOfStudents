class TeamsController < ApplicationController

  def is_my?
    return current_user == Team.find(params[:id]||params[:team_id]).battle.owner
  end
  def is_my_battle?
    return current_user == Battle.find(params[:battle_id]).owner
  end

  access_control do
    allow :teacher, :to=>[:new, :create], :if=>:is_my_battle?
    allow :teacher, :to=>[:destroy, :unassign], :if=>:is_my?
    allow :student, :to=>[:assign]
    allow all, :to=>[:show]
  end
  def new
    @battle = Battle.find(params[:battle_id])
    @team = Team.new
  end

  def create
    @battle = Battle.find(params[:battle_id])
    @team = Team.new(params.require(:team).permit(:name, :max_stud, :color))
    @team.battle = @battle
    if @team.save
      if not @battle.config["t_conf"].empty?
        conf = @battle.config["t_conf"]
        conf.each do |c|
          c["count"].to_i.times do
            TaskType.find(c["type"]).generate_task_for(@team, @battle, c["level"])
          end
        end
      end
      redirect_to battle_manage_path @battle
    else
      render 'new'
    end
  end

  def show
    @team = Team.find(params[:id])
  end
  def destroy
    @team = Team.find(params[:id])
    @team.destroy
    redirect_to battle_manage_path Battle.find(params[:battle_id])
  end
  def assign
    @team = Team.find(params[:team_id])
    if @team.students.size == @team.max_stud.to_i
      redirect_to :back, :flash=>{:alert=>"В команде \""+@team.name+"\" все места заняты"}
      return
    end
    sb = current_user.student_battles.where(:battle_id=>@team.battle.id).first
    sb.team = @team
    sb.status = "inTeam"
    sb.team_assign_time = Time.now if sb.team_assign_time.nil?
    sb.save
    current_user.clear_score(@team.battle)
    redirect_to :root
  end

  def unassign
    @team = Team.find(params[:team_id])
    sb = User.find(params[:student]).student_battles.where(:team_id=>@team).first
    sb.team = nil
    sb.status = "teamChoose"
    sb.save
    sb.student.clear_score(@team.battle)
    redirect_to [@team.battle, @team]
  end
end
