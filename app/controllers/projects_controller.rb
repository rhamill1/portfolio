require 'date'

class ProjectsController < ApplicationController

  before_action :get_project, only: [:show]

  def index
    @projects = Project.all
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.create(project_params)
    @project.save
    redirect_to root_path
  end

  def show
  end

  private

  def project_params
    params.require(:project).permit(:project_name,:description,:sub_title,:primary_image,:index_image,:github,:url,:tech,:completion_date, :slug)
  end

  def get_project
    @project = Project.friendly.find(params[:id])
  end

end
