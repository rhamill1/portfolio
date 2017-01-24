require 'date'
require 'json'

class ProjectsController < ApplicationController

  before_action :get_project, only: [:show]

  def index
    @projects = Project.all

    Aws.config.update(
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_KEY"],
      force_path_style: true,
      region: ENV["AWS_REGION"]
    )

    s3_client = Aws::S3::Client.new

    final_array_dirty = s3_client.get_object(bucket: 'portfolio-json', key: 'final_array.json').body.read
    final_array = JSON.parse(final_array_dirty)

    first_monday_o_month_array_dirty = s3_client.get_object(bucket: 'portfolio-json', key: 'first_monday_o_month_array.json').body.read
    first_monday_o_month_array = JSON.parse(first_monday_o_month_array_dirty)


    @chart = LazyHighCharts::HighChart.new('graph') do |f|

      f.xAxis(categories: first_monday_o_month_array)
      f.yAxis(
        gridLineWidth: 0,
        labels: {
          enabled: false
        },
        title: {
          enabled: false
        }
      )
      final_array.each do |project|
        f.series(name: project[0], yAxis: 0, data: project[1], marker: {enabled: false})
      end

      f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical', enabled: false)
      f.colors(["#ecd292", "#e5a267", "#d27254", "#a5494d", "#63223c"])
      f.chart(defaultSeriesType: "area", backgroundColor:'transparent')
      f.tooltip(backgroundColor:'#e5e5e5', headerFormat: '')

    end


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
