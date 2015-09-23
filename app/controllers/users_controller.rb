class UsersController < ApplicationController
  
  def is_my?
    return current_user == User.find(params[:id])
  end
  
  access_control do
    allow :admin, :to=>[:new, :edit, :create, :update, :destroy, :reset_password, :update_password, :show]
    allow logged_in, :to=>[:show], :if=>:is_my?
  end

  def show
    @user = User.find(params[:id])
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
