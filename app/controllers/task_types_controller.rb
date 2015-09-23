class TaskTypesController < ApplicationController
  access_control do
    allow :task_manager
  end

  def show
    @task_type = TaskType.find(params[:id])
  end

  def new
    @task_type = TaskType.new
    @task_type.config = {}
  end
  def create
    @task_type = TaskType.new(params.require(:task_type).permit(:name, :text).tap { |wl| wl[:config] = params[:task_type][:config]})
    @task_type.config["vars"] = @task_type.config["vars"] || {}
    @task_type.config["levels"].each do |lk, lv|
      @task_type.config["levels"][lk]["vars"] = lv["vars"] || {}
    end
    if @task_type.save
      redirect_to @task_type
    else
      render 'new'
    end
  end
  def edit
    @task_type = TaskType.find(params[:id])
  end
  def update
    @task_type = TaskType.find(params[:id])
    if @task_type.update(params.require(:task_type).permit(:name, :text).tap { |wl| wl[:config] = params[:task_type][:config]})
      @task_type.config["vars"] = @task_type.config["vars"] || {}
      @task_type.config["levels"].each do |lk, lv|
        @task_type.config["levels"][lk]["vars"] = lv["vars"] || {}
      end
      @task_type.save
      redirect_to @task_type
    else
      render 'edit'
    end
  end

end
