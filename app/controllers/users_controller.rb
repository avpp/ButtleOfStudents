class UsersController < ApplicationController
  
  def is_my?
    return current_user == User.find(params[:id])
  end
  def is_my_student?
    return User.find(params[:id]).chef == current_user
  end
  def is_try_create_only_student?
    return ((not params[:roles].nil?) and (params[:roles].size == 1) and (params[:roles][0] == "student"))
  end
  
  access_control do
    allow :admin, :to=>[:new, :edit, :create, :update, :destroy, :reset_password, :update_password, :show, :index]
    allow :teacher, :to=>[:new, :index]
    allow :teacher, :to=>[:create], :if=>:is_try_create_only_student?
    allow :teacher, :to=>[:edit, :update, :destroy, :reset_password, :update_password, :show], :if=>:is_my_student?
    allow logged_in, :to=>[:show], :if=>:is_my?
  end

  def index
    @otherU = (current_user.has_role? :admin)? (User.where(:id=>User.joins(:roles).where.not(:roles=>{:name=>"student"}).map {|x| x.id} || []).where.not(:id=>current_user.id)): []
    @studU = User.where(:id=>User.joins(:roles).where(:roles=>{:name=>"student"}).map {|x| x.id} || [])
    @studU = @studU.where(:chef_id=>current_user.id) if current_user.has_role? :teacher
  end

  def show
    @user = User.find(params[:id])
    if current_user == @user
      (redirect_to users_path; return) if current_user.has_role?(:admin)
      (redirect_to users_path; return) if current_user.has_role?(:teacher)
      
    end
    if @user.has_role?(:student)
      @battle = @user.in_battles.where(:end_time=>nil).first
      return if @battle.nil?
      stud_b = @user.student_battles.where(:battle_id=>@battle.id).first
      status = stud_b.status || "qualification"
      if status == "qualification"
        render 'users/student_battle_q.html.erb'
      elsif status == "teamChoose"
        render 'users/student_battle_ct.html.erb'
      elsif status == "inTeam"
        @team = stud_b.team
        render 'users/student_battle_t.html.erb'
      end
    end
    
  end

  def new
    @user = User.new()
  end
  def edit
    @user = User.find(params[:id])
  end
  def update
    @user = User.find(params[:id])
    @user.info[:personal] = params[:personal] || {}
    @user.info[:additional] = params[:additional] || {}
    if (params["roles"].nil? or params["roles"].size == 0)
      @user.errors.add(:role, "Пользователь должен иметь роль")
      render 'new'
      return
    end
    @user.save
    new_roles = params["roles"]
    @user.roles.each do |r|
      if new_roles.include?(r.name.to_s)
        new_roles.delete(r.name.to_s)
      else
        @user.has_no_role!(r.name.to_s)
      end
    end
    new_roles.each do |r|
      @user.has_role!(r)
    end
    redirect_to @user
  end

  def create
    @user = User.new(params["user"].permit(:email, :password, :password_confirmation))
    @user.info[:personal] = params[:personal] || {}
    @user.info[:additional] = params[:additional] || {}
    if (params["roles"].nil? or params["roles"].size == 0)
      @user.errors.add(:role, "Пользователь должен иметь роль")
      render 'new'
      return
    end
    if @user.save
      params["roles"].each do |r|
        @user.has_role!(r.to_sym)
      end
      if @user.has_role? :student and current_user.has_role? :teacher
        @user.chef = current_user
        @user.save!
      end
      redirect_to @user
    else
      print @user.errors.count
      @user.errors.full_messages.each {|m| print "\n", m, "\n"}
      render 'new'
    end
  end
  def destroy
    u = User.find(params[:id])
    u.destroy
    redirect_to current_user
  end

  def reset_password
    @user = User.find(params[:id])
  end

  def update_password
    u = User.find(params[:id])
    u.update(params.require(:user).permit(:password, :password_confirmation))
    u.save
    redirect_to u
  end

end
